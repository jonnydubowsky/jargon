# frozen_string_literal: true

# A trail is one research session: the ordered sequence of questions asked and
# pages opened — the associative path from one idea to the next (Bush's memex
# trails). Pages and insights land in the global library as usual; the trail is
# the temporal layer on top.
class Trail < ApplicationRecord
  has_many :trail_steps, -> { order(:position) }, dependent: :destroy, inverse_of: :trail

  def display_name
    name.presence || "Untitled trail"
  end

  def record_search!(query)
    return if latest_step&.searched? && latest_step.query == query

    append_step!(action: :searched, query:).tap { autoname!(query) }
  end

  def record_opened!(article)
    return if latest_step&.opened? && latest_step.subject == article

    append_step!(action: :opened, subject: article)
  end

  def record_explored!(search)
    return if latest_step&.explored? && latest_step.subject == search

    append_step!(action: :explored, subject: search)
  end

  def latest_step
    trail_steps.last
  end

  def latest_opened_article
    trail_steps.opened.last&.subject
  end

  private

  def append_step!(attributes)
    trail_steps.create!(attributes.merge(position: next_position))
  end

  def next_position
    (trail_steps.maximum(:position) || 0) + 1
  end

  def autoname!(query)
    update!(name: query.truncate(80)) if name.blank?
  end
end
