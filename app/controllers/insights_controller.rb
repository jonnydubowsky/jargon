# frozen_string_literal: true

class InsightsController < ApplicationController
  def show
    @insight = Insight.resolve_identifier!(params[:id])

    return redirect_to @insight.parent, status: :moved_permanently if @insight.has_parent?

    redirect_to @insight, status: :moved_permanently if @insight.slug.present? && @insight.slug != params[:id]

    if @insight.has_children?
      @source_articles = @insight.children
                                 .includes(article: [{ parent: :children }, :children])
                                 .filter_map { |i| i.article&.parent || i.article }
                                 .uniq

      exclude_items = [@insight] + @source_articles + @insight.sibling_insights
    else
      exclude_items = [@insight, @insight.article].compact + @insight.sibling_insights
    end

    @similar_items = SimilarItemsQuery.new(
      embedding: @insight.embedding,
      limit: 8,
      exclude: exclude_items
    ).call
  end

  def save
    @insight = Insight.resolve_identifier!(params[:id])
    result = @insight.save_to_account

    if result.unconfigured?
      redirect_to @insight, alert: "Set JARGON_VAULT_PATH to save a markdown note, or INFRANODUS_API_KEY to export to InfraNodus."
    elsif result.error?
      redirect_to @insight, alert: result.notice
    else
      redirect_to @insight, notice: result.notice
    end
  end
end
