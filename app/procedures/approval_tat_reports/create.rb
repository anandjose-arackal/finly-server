class ApprovalTatReports::Create < Transactions::API

  step :run_background_job

  def run_background_job(options, params:, current_user:, **)
    add_message options, :success, :base, "Approval Tat report export file has been initiated. You will receive an email shortly."
    ApprovalTatReports::TatExport.call_async(params: params, current_user: current_user)
    true
  end

end