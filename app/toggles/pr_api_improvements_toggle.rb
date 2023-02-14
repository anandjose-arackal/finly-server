# release/pf#pr_api_improvement
class PrApiImprovementsToggle < ApplicationToggle

    def enabled?
      feature_flag 'release/pf#pr_api_improvement', false
    end
  
  end
  