# frozen_string_literal: true

# The search front door: ask a question, see live web results, open one in the
# reader. Every query and page-open is recorded as a step on the current trail.
class CompanionController < ApplicationController
  def index
    @query = params[:q].to_s.strip

    return if @query.blank?

    return redirect_to_reader(@query) if url?(@query)

    run_search
  end

  private

  def run_search
    @results = ExaClient.new.search(query: @query)["results"] || []
    current_trail!.record_search!(@query)
  rescue StandardError => e
    Rails.logger.error("Companion search failed: #{e.message}")
    @search_error = "Web search is unavailable right now. Check the EXA_API_KEY or try again."
  end

  def redirect_to_reader(url)
    article = Article.find_or_create_by!(url:)
    current_trail!.record_opened!(article)
    redirect_to article
  end

  def url?(input)
    input.match?(%r{\Ahttps?://}i)
  end
end
