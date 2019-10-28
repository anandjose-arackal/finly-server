module Forms
  module Definitions
    module Types
      class RadioButton < Entity
        register :radio_button
        hint 'Select option'

        consumes_choices!
      end
    end
  end
end