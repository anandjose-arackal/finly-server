# release/pf#forms_debounce_on_field
class FormsDebounceOnFieldToggle < ApplicationToggle
    def enabled?
      feature_flag 'release/pf#forms_debounce_on_field', false
    end
end
  