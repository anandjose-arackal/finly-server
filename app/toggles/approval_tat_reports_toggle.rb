class ApprovalTatReportsToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/approval_tat_reports', false
  end

end