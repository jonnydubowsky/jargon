# frozen_string_literal: true

require "rails_helper"

RSpec.describe Prompt do
  describe ".fetch" do
    it "returns the default when no override exists" do
      expect(Prompt.fetch("lens.instructions", default: "default text")).to eq("default text")
    end

    it "returns the stored override when one exists" do
      Prompt.override!("lens.instructions", "edited text")

      expect(Prompt.fetch("lens.instructions", default: "default text")).to eq("edited text")
    end
  end

  describe ".override! / .reset!" do
    it "updates an existing override in place" do
      Prompt.override!("k", "one")
      Prompt.override!("k", "two")

      expect(Prompt.where(key: "k").count).to eq(1)
      expect(Prompt.fetch("k", default: "d")).to eq("two")
    end

    it "reset! removes the override and overridden? reflects it" do
      Prompt.override!("k", "one")
      expect(Prompt.overridden?("k")).to be(true)

      Prompt.reset!("k")

      expect(Prompt.overridden?("k")).to be(false)
      expect(Prompt.fetch("k", default: "d")).to eq("d")
    end
  end
end
