# frozen_string_literal: true

require "rails_helper"

RSpec.describe Insight do
  describe "#save_to_account" do
    it "writes a vault note and stubs InfraNodus without credentials" do
      insight = create(:insight, title: "Key Insight")

      Dir.mktmpdir do |dir|
        allow(Insight::VaultNote).to receive(:vault_path).and_return(dir)
        allow(Insight::VaultNote).to receive(:insights_folder).and_return("Insights")

        result = insight.save_to_account

        expect(result.vault).to be_written
        expect(result.infranodus).to be_stubbed
        expect(File).to exist(File.join(dir, "Insights", "#{insight.slug}.md"))
        expect(result.notice).to include("Saved markdown note")
        expect(result.notice).to include("InfraNodus skipped")
      end
    end
  end
end
