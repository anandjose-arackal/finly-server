# release/amount_prop_only_load_toggle
class AmountPropOnlyLoadToggle < ApplicationToggle
    def enabled?
      feature_flag 'release/amount_prop_only_load_toggle', false
    end
end
  