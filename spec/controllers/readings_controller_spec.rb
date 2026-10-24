# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReadingsController do
  describe "POST #create" do
    it "ingests the URL and records an opened step" do
      allow(IngestArticleJob).to receive(:perform_later)

      post :create, params: { url: "https://example.com/new", title: "New Article" }

      article = Article.find_by!(url: "https://example.com/new")
      expect(article.title).to eq("New Article")
      expect(response).to redirect_to(article)

      trail = Trail.find(session[:trail_id])
      expect(trail.trail_steps.sole).to have_attributes(action: "opened", subject: article)
    end

    it "reuses an existing article for the same URL" do
      article = create(:article, url: "https://example.com/existing")

      post :create, params: { url: "https://example.com/existing" }

      expect(response).to redirect_to(article)
      expect(Article.where(url: "https://example.com/existing").count).to eq(1)
    end

    it "redirects home when the URL is missing" do
      post :create, params: { url: "" }

      expect(response).to redirect_to(root_path)
    end
  end
end
