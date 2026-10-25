# frozen_string_literal: true

require "rails_helper"

RSpec.describe PromptsController do
  let(:key) { NegativeSpaceQuery::PROMPT_KEY }

  describe "PATCH #update" do
    it "stores an override for a known key" do
      patch :update, params: { key:, content: "my custom prompt" }

      expect(Prompt.fetch(key, default: "d")).to eq("my custom prompt")
    end

    it "resets instead of storing when the content equals the default" do
      Prompt.override!(key, "edited")

      patch :update, params: { key:, content: NegativeSpaceQuery::INSTRUCTIONS }

      expect(Prompt.overridden?(key)).to be(false)
    end

    it "rejects unknown keys" do
      expect do
        patch :update, params: { key: "nope", content: "x" }
      end.to raise_error(ActionController::BadRequest)

      expect(Prompt.count).to eq(0)
    end
  end

  describe "DELETE #destroy" do
    it "removes the override" do
      Prompt.override!(key, "edited")

      delete :destroy, params: { key: }

      expect(Prompt.overridden?(key)).to be(false)
    end
  end
end
