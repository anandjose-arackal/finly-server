module Forms
  module Definitions
    module Types
      class Lookup < Entity
        register :lookup
        hint 'Select value'

        consumes_choices!
      end
    end
  end
end