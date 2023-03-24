# release/pf#forms_removed_clonedeep
class FormsRemoveClonedeepToggle < ApplicationToggle
    def enabled?
      feature_flag 'release/pf#forms_removed_clonedeep', false
    end
end
  