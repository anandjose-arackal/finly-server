# release/forms#dynamic_autocomplete_choices
class FormsDynamicAutocompleteChoicesEnabled < ApplicationToggle

  def enabled?
    feature_flag 'release/forms#dynamic_autocomplete_choicess', false
  end

end
