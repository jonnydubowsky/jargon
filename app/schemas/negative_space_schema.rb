# frozen_string_literal: true

class NegativeSpaceSchema < RubyLLM::Schema
  array :gaps, description: "The most significant blind spots in the collection",
               min_items: 1,
               max_items: 5 do
    object do
      string :title, max_length: 100,
                     description: "Short name (a few words) for the missing subject or unasked question"
      string :rationale, max_length: 500,
                         description: "Why this absence matters — what its presence would change (1-3 sentences)"
      string :question, max_length: 160,
                        description: "One specific, concise research question that would begin to fill this gap"
      integer :confidence, minimum: 0, maximum: 100,
                           description: "Calibrated confidence (0-100) that this is a real, significant blind spot. Be honest; do not inflate."
      string :certainty_basis, max_length: 120,
                               description: "One short phrase on what that confidence rests on (e.g. 'several sources circle it, none address it' or 'inferred, thin evidence')"
    end
  end
end
