# release/pf#dashboard_card_expansion
class DashboardCardExpansionToggle < ApplicationToggle
    def enabled?
      feature_flag 'release/pf#dashboard_card_expansion', false
    end
end
  