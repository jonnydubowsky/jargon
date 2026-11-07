# frozen_string_literal: true

# Edits the exposed prompts (the glass box, editable). Only known registry
# keys can be overridden; a reset deletes the override and the in-code
# default takes over again.
class PromptsController < ApplicationController
  KNOWN_KEYS = [NegativeSpaceQuery::PROMPT_KEY].freeze

  def update
    key = known_key!
    content = params[:content].to_s.strip

    if content.blank? || content == default_for(key)&.strip
      Prompt.reset!(key)
    else
      Prompt.override!(key, content)
    end

    redirect_back_or_to(root_path)
  end

  def destroy
    Prompt.reset!(known_key!)
    redirect_back_or_to(root_path)
  end

  private

  def known_key!
    params[:key].to_s.tap do |key|
      raise ActionController::BadRequest, "unknown prompt key" unless KNOWN_KEYS.include?(key)
    end
  end

  def default_for(key)
    case key
    when NegativeSpaceQuery::PROMPT_KEY then NegativeSpaceQuery::INSTRUCTIONS
    end
  end
end
