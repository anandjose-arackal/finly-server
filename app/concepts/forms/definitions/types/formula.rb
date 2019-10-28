module Forms
  module Definitions
    module Types
      class Formula < Entity
        register :formula
        hint 'Auto-Generated'
        editable false
        can_editable_be_changed false

        consumes_choices!
      end
    end
  end
end