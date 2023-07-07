# release/forms#auto_select_on_single_choice_dropdown
class FormsDropdownAutoselectOnSingleChoice < ApplicationToggle
    def enabled?
      feature_flag 'release/forms#auto_select_on_single_choice_dropdown', false
    end
end
  