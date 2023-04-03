class ApprovalTatReports::Create < Transactions::API
  
  step :check_feature_flag
  step :run_background_job

  def check_feature_flag(options,params:, current_user:, **)
    unless ApprovalTatReportsToggle.new(current_user).enabled?
      add_message options, :error, :base, "Tat reports feature is not enabled"
      return false
    end
    true
  end

  def run_background_job(options, params:, current_user:, **)
    add_message options, :success, :base, "Approval Tat report export file has been initiated. You will receive an email shortly."
    ApprovalTatReports::TatExport.call_async(params: params, current_user: current_user)
    true
  end

end