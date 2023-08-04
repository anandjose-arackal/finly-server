# release/pf#dashboard_auto_expand_cards
class DashboardAutoExpandCardsToggle < ApplicationToggle
    def enabled?
      feature_flag 'release/pf#dashboard_auto_expand_cards', false
    end
end
  