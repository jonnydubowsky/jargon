# frozen_string_literal: true

require "rails_helper"

RSpec.describe QueriesController do
  before { allow(SearchJob).to receive(:perform_later) }

  describe "POST #create" do
    it "records an explored step on the current trail" do
      trail = Trail.create!
      session[:trail_id] = trail.id

      post :create, params: { q: "what about embeddings?" }

      search = Search.find_by!(query: "what about embeddings?")
      expect(response).to redirect_to(search)
      expect(trail.trail_steps.explored.sole.subject).to eq(search)
    end

    it "does not start a trail when none is underway" do
      post :create, params: { q: "what about embeddings?" }

      expect(Trail.count).to eq(0)
      expect(response).to redirect_to(Search.sole)
    end

    it "skips a consecutive duplicate explore of the same search" do
      trail = Trail.create!
      session[:trail_id] = trail.id

      post :create, params: { q: "same question" }
      post :create, params: { q: "same question" }

      expect(trail.trail_steps.count).to eq(1)
    end
  end
end
