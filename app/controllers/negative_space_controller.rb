# frozen_string_literal: true

class NegativeSpaceController < ApplicationController
  def index
    @trail = Trail.find_by(id: params[:trail_id]) if params[:trail_id].present?

    return if params[:run].blank?

    @analysis = NegativeSpaceQuery.new(
      topic: params[:topic],
      model: params[:model].presence || NegativeSpaceQuery::DEFAULT_MODEL,
      trail: @trail
    ).call
  end
end
