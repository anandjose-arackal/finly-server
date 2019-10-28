module Forms
  module Definitions
    module Types
      class CheckBox < Entity
        register :checkbox
        hint 'Select option'
        multiple true

        consumes_choices!

        option :min_choices
        option :max_choices

        contract do
          optional(:min_choices).value(:int?)
          optional(:max_choices).value(:int?)
        end
      end
    end
  end
end