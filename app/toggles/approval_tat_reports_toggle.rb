class ApprovalTatReportsToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/approval_tat_reports#enabled', false
  end

  def max_limit
    feature_value 'release/approval_tat_reports#max_limit', 0
  end

end