# frozen_string_literal: true

require "rails_helper"

RSpec.describe Insight::VaultNote do
  def parse_note(markdown)
    _empty, yaml, body = markdown.split("---", 3)
    [YAML.safe_load(yaml), body.to_s.strip]
  end

  describe "#to_markdown" do
    it "includes YAML front matter with title, created, source, tags, and stable id" do
      insight = create(:insight, title: "Key Insight", body: "The main takeaway from the article.", snippet: "Original text from the source.")

      markdown = described_class.new(insight, vault_path: "/tmp/unused").to_markdown
      front_matter, body = parse_note(markdown)

      expect(front_matter["title"]).to eq("Key Insight")
      expect(front_matter["created"]).to eq(insight.created_at.utc.iso8601)
      expect(front_matter["source"]).to eq(insight.article.url)
      expect(front_matter["source_title"]).to eq(insight.article.title)
      expect(front_matter["tags"]).to eq(%w[insight jargon])
      expect(front_matter["id"]).to eq(insight.nanoid)
      expect(body).to include("The main takeaway from the article.")
      expect(body).to include("## Evidence")
      expect(body).to include("Original text from the source.")
    end

    it "converts strong tags to markdown emphasis" do
      insight = create(:insight, body: "The <strong>main takeaway</strong> from the article.", snippet: nil)

      _front_matter, body = parse_note(described_class.new(insight, vault_path: "/tmp/unused").to_markdown)

      expect(body).to eq("The **main takeaway** from the article.")
    end

    it "omits source when the insight has no article" do
      insight = create(:insight, :parent)
      insight.update!(article: nil)

      front_matter, = parse_note(described_class.new(insight, vault_path: "/tmp/unused").to_markdown)

      expect(front_matter).not_to have_key("source")
      expect(front_matter).not_to have_key("source_title")
      expect(front_matter["id"]).to eq(insight.nanoid)
    end

    it "omits the evidence section when there is no snippet" do
      insight = create(:insight, snippet: nil)

      _front_matter, body = parse_note(described_class.new(insight, vault_path: "/tmp/unused").to_markdown)

      expect(body).not_to include("## Evidence")
    end
  end

  describe "#write" do
    it "writes a markdown file into the vault insights folder" do
      insight = create(:insight, title: "Key Insight")

      Dir.mktmpdir do |dir|
        result = described_class.new(insight, vault_path: dir).write

        expect(result).to be_written
        expect(result.path).to eq(File.join(dir, "Insights", "#{insight.slug}.md"))
        expect(File.read(result.path)).to include("id: #{insight.nanoid}")
      end
    end

    it "skips when no vault path is configured" do
      insight = create(:insight)

      result = described_class.new(insight, vault_path: nil).write

      expect(result).to be_skipped
      expect(result.message).to include("JARGON_VAULT_PATH")
    end

    it "refuses a destination that would escape the vault" do
      insight = create(:insight)

      Dir.mktmpdir do |dir|
        result = described_class.new(insight, vault_path: dir, folder: "../outside").write

        expect(result).to be_error
        expect(Dir.children(dir)).to be_empty
      end
    end
  end

  describe ".insights_folder" do
    it "drops path traversal segments from the configured folder" do
      original = ENV.fetch("JARGON_VAULT_INSIGHTS_FOLDER", nil)
      ENV["JARGON_VAULT_INSIGHTS_FOLDER"] = "../Insights/../Cards"

      expect(described_class.insights_folder).to eq("Insights/Cards")
    ensure
      if original
        ENV["JARGON_VAULT_INSIGHTS_FOLDER"] = original
      else
        ENV.delete("JARGON_VAULT_INSIGHTS_FOLDER")
      end
    end
  end
end
