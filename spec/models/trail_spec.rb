# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trail do
  describe "#record_search!" do
    it "appends a searched step and names the trail after the first query" do
      trail = Trail.create!

      trail.record_search!("ruby fibers")

      expect(trail.trail_steps.sole).to have_attributes(action: "searched", query: "ruby fibers", position: 1)
      expect(trail.reload.name).to eq("ruby fibers")
    end

    it "skips a consecutive duplicate of the same query" do
      trail = Trail.create!

      trail.record_search!("ruby fibers")
      trail.record_search!("ruby fibers")

      expect(trail.trail_steps.count).to eq(1)
    end

    it "does not rename an already-named trail" do
      trail = Trail.create!(name: "my session")

      trail.record_search!("ruby fibers")

      expect(trail.reload.name).to eq("my session")
    end
  end

  describe "#record_explored!" do
    it "appends an explored step and skips a consecutive duplicate" do
      trail = Trail.create!
      search = create(:search)

      trail.record_explored!(search)
      trail.record_explored!(search)

      expect(trail.trail_steps.explored.sole.subject).to eq(search)
    end
  end

  describe "#record_opened!" do
    it "appends an opened step with increasing positions" do
      trail = Trail.create!
      article = create(:article)

      trail.record_search!("ruby fibers")
      trail.record_opened!(article)

      step = trail.trail_steps.opened.sole
      expect(step).to have_attributes(subject: article, position: 2)
    end

    it "skips a consecutive duplicate open of the same article" do
      trail = Trail.create!
      article = create(:article)

      trail.record_opened!(article)
      trail.record_opened!(article)

      expect(trail.trail_steps.count).to eq(1)
    end
  end
end
