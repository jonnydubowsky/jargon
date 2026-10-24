# frozen_string_literal: true

class TrailStep < ApplicationRecord
  belongs_to :trail, inverse_of: :trail_steps
  belongs_to :subject, polymorphic: true, optional: true

  enum :action, { searched: 0, opened: 1, explored: 2 }, scopes: true

  validates :position, presence: true, uniqueness: { scope: :trail_id }
  validates :query, presence: true, if: :searched?
  validates :subject, presence: true, unless: :searched?
end
