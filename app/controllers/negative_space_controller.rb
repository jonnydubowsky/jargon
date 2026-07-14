# frozen_string_literal: true

class NegativeSpaceController < ApplicationController
  def index
    return unless params[:run].present?

    @analysis = NegativeSpaceQuery.new(
      topic: params[:topic],
      model: params[:model].presence || NegativeSpaceQuery::DEFAULT_MODEL
    ).call
  end
end
