# frozen_string_literal: true

# Opens a search result in the in-app reader: the article is ingested through
# the existing pipeline and the page-open lands on the current trail.
class ReadingsController < ApplicationController
  def create
    url = params[:url].to_s.strip

    return redirect_to root_path, alert: "Missing URL" if url.blank?

    article = Article.find_or_create_by!(url:) do |a|
      a.title = params[:title].presence
    end

    current_trail!.record_opened!(article)

    redirect_to article
  end
end
