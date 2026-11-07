# frozen_string_literal: true

class Insight
  class SaveResult
    def initialize(vault:, infranodus:)
      @vault = vault
      @infranodus = infranodus
    end

    attr_reader :vault, :infranodus

    def notice
      [vault&.message, infranodus&.message].compact_blank.join(" ")
    end

    def unconfigured?
      vault&.skipped? && infranodus&.stubbed?
    end

    def error?
      vault&.error? || infranodus&.error?
    end
  end
end
