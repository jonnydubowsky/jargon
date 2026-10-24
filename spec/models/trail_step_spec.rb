# frozen_string_literal: true

require "rails_helper"

RSpec.describe TrailStep do
  it "requires a query for searched steps" do
    step = TrailStep.new(trail: Trail.create!, action: :searched, position: 1)

    expect(step).not_to be_valid
    expect(step.errors[:query]).to be_present
  end

  it "requires a subject for opened steps" do
    step = TrailStep.new(trail: Trail.create!, action: :opened, position: 1)

    expect(step).not_to be_valid
    expect(step.errors[:subject]).to be_present
  end

  it "rejects duplicate positions within a trail" do
    trail = Trail.create!
    trail.record_search!("a")

    step = TrailStep.new(trail:, action: :searched, query: "b", position: 1)

    expect(step).not_to be_valid
  end
end
