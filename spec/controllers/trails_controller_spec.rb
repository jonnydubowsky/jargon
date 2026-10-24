# frozen_string_literal: true

require "rails_helper"

RSpec.describe TrailsController do
  render_views

  describe "GET #show" do
    it "renders the trail's steps in order" do
      trail = Trail.create!
      trail.record_search!("ruby fibers")
      trail.record_opened!(create(:article, title: "Fibers Deep Dive"))

      get :show, params: { id: trail.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ruby fibers")
      expect(response.body).to include("Fibers Deep Dive")
    end
  end

  describe "PATCH #update" do
    it "renames the trail" do
      trail = Trail.create!(name: "old")

      patch :update, params: { id: trail.id, trail: { name: "new name" } }

      expect(trail.reload.name).to eq("new name")
      expect(response).to redirect_to(trail)
    end
  end

  describe "POST #create" do
    it "starts a fresh trail by clearing the session" do
      session[:trail_id] = Trail.create!.id

      post :create

      expect(session[:trail_id]).to be_nil
      expect(response).to redirect_to(root_path)
    end
  end
end
