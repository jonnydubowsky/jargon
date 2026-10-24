# frozen_string_literal: true

# A user override for one of the exposed prompts (the glass box, editable).
# Defaults live in code next to the feature they drive; a Prompt row exists
# only while the user has edited that prompt away from its default.
class Prompt < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :content, presence: true

  # The effective prompt for a key: the stored override, or the in-code default.
  def self.fetch(key, default:)
    where(key: key.to_s).pick(:content) || default
  end

  def self.override!(key, content)
    find_or_initialize_by(key: key.to_s).update!(content:)
  end

  def self.reset!(key)
    where(key: key.to_s).destroy_all
  end

  def self.overridden?(key)
    exists?(key: key.to_s)
  end
end
