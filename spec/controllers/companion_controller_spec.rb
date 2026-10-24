# frozen_string_literal: true

require "rails_helper"

RSpec.describe CompanionController do
  render_views

  def stub_exa(results)
    client = instance_double(ExaClient, search: { "results" => results })
    allow(ExaClient).to receive(:new).and_return(client)
    client
  end

  describe "GET #index" do
    it "renders the search box without a query" do
      get :index

      expect(response).to have_http_status(:ok)
    end

    it "shows Exa results and records a searched step on the current trail" do
      stub_exa([{ "url" => "https://example.com/a", "title" => "A" }])

      get :index, params: { q: "ruby fibers" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("https://example.com/a")

      trail = Trail.find(session[:trail_id])
      expect(trail.trail_steps.sole).to have_attributes(action: "searched", query: "ruby fibers")
    end

    it "reuses the session trail across searches" do
      stub_exa([])

      get :index, params: { q: "first" }
      get :index, params: { q: "second" }

      expect(Trail.count).to eq(1)
      expect(Trail.sole.trail_steps.pluck(:query)).to eq(%w[first second])
    end

    it "renders a friendly error when Exa fails" do
      client = instance_double(ExaClient)
      allow(client).to receive(:search).and_raise(StandardError, "boom")
      allow(ExaClient).to receive(:new).and_return(client)

      get :index, params: { q: "ruby fibers" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Web search is unavailable")
    end

    it "treats a pasted URL as opening the reader" do
      allow(IngestArticleJob).to receive(:perform_later)

      get :index, params: { q: "https://example.com/paste" }

      article = Article.find_by!(url: "https://example.com/paste")
      expect(response).to redirect_to(article)
      expect(Trail.sole.trail_steps.sole).to have_attributes(action: "opened", subject: article)
    end
  end
end
