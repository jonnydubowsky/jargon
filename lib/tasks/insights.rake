# frozen_string_literal: true

namespace :insights do
  desc "Save an insight to the vault (and InfraNodus if configured). Usage: bin/rails insights:save[slug-or-nanoid]"
  task :save, [:identifier] => :environment do |_t, args|
    identifier = args[:identifier].presence || ENV["INSIGHT"].presence
    abort "Pass an insight slug or nanoid: bin/rails insights:save[slug-or-nanoid]" if identifier.blank?

    insight = Insight.resolve_identifier(identifier)
    abort "Insight not found: #{identifier}" unless insight

    result = insight.save_to_account
    puts result.notice
    abort if result.error?
  end
end
