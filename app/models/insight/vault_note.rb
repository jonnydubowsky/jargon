# frozen_string_literal: true

class Insight
  class VaultNote
    Result = Data.define(:status, :path, :message) do
      def written? = status == :written
      def skipped? = status == :skipped
      def error? = status == :error
    end

    DEFAULT_FOLDER = "Insights"

    def self.vault_path
      ENV["JARGON_VAULT_PATH"].presence
    end

    def self.insights_folder
      raw = ENV.fetch("JARGON_VAULT_INSIGHTS_FOLDER", DEFAULT_FOLDER)
      raw.to_s.split(%r{[\\/]}).reject { |part| part.blank? || part == "." || part == ".." }.join(File::SEPARATOR)
    end

    def initialize(insight, vault_path: self.class.vault_path, folder: self.class.insights_folder)
      @insight = insight
      @vault_path = vault_path
      @folder = folder
    end

    def write
      return skipped("Vault skipped (JARGON_VAULT_PATH not set).") if @vault_path.blank?

      path = destination
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, to_markdown)

      Result.new(status: :written, path:, message: "Saved markdown note to #{display_path(path)}.")
    rescue SystemCallError, ArgumentError => e
      Rails.logger.error("Insight::VaultNote failed for #{@insight.nanoid}: #{e.class}")
      Result.new(status: :error, path: nil, message: "Vault save failed.")
    end

    def to_markdown
      body = [body_markdown, evidence_section].compact_blank.join("\n\n")

      <<~MARKDOWN
        ---
        #{front_matter_yaml}---

        #{body}
      MARKDOWN
    end

    private

    def skipped(message)
      Result.new(status: :skipped, path: nil, message:)
    end

    def destination
      root = File.expand_path(@vault_path)
      relative = File.join(*[@folder.presence, filename].compact)
      path = File.expand_path(relative, root)

      raise ArgumentError, "Vault note path would escape JARGON_VAULT_PATH" unless path == root || path.start_with?("#{root}#{File::SEPARATOR}")

      path
    end

    def filename
      "#{@insight.to_param}.md"
    end

    def display_path(path)
      relative = Pathname.new(path).relative_path_from(Pathname.new(File.expand_path(@vault_path)))
      relative.to_s
    rescue ArgumentError
      filename
    end

    def front_matter
      {
        "title" => @insight.title,
        "created" => @insight.created_at&.utc&.iso8601,
        "source" => source_url,
        "source_title" => source_title,
        "tags" => tags,
        "id" => @insight.nanoid
      }.compact
    end

    def front_matter_yaml
      YAML.dump(front_matter).delete_prefix("---\n").gsub(/\n\.\.\.\s*\z/, "\n")
    end

    def body_markdown
      to_markdown_text(@insight.body).presence || @insight.title.to_s
    end

    def evidence_section
      snippet = to_markdown_text(@insight.snippet)
      return if snippet.blank?

      "## Evidence\n\n#{snippet}"
    end

    def to_markdown_text(text)
      text.to_s
          .gsub(%r{<strong>(.*?)</strong>}m, '**\1**')
          .gsub(/<[^>]+>/, "")
          .strip
    end

    def source_url
      @insight.article&.url.presence
    end

    def source_title
      @insight.article&.title.presence
    end

    def tags
      %w[insight jargon]
    end
  end
end
