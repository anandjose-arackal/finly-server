#'release/approval_tat_reports_optimize'
class ApprovalTatReportsOptimizeToggle < ApplicationToggle
  
  def enabled?
    feature_flag 'release/approval_tat_reports_optimize', false
  end

end
