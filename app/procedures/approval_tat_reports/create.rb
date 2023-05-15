class ApprovalTatReports::Create < Transactions::API

  step :check_feature_flag
  step :check_open_status_records
  step :run_background_job

  def check_feature_flag(options,params:, current_user:, **)
    unless ApprovalTatReportsToggle.new(current_user).enabled?
      add_message options, :error, :base, "Tat reports feature is not enabled"
      return false
    end
    true
  end

  def check_open_status_records(options, params:, current_user:, **)
    params[:tat_report_paginate] = true
    index_result = IndexBuilder::Show.(params: params, current_user: current_user)
    total_index_result_count = index_result['model.records']&.count
    open_status_documents_count = index_result['model.records'].where(submitted_at: nil)&.count

    if total_index_result_count == open_status_documents_count
      add_message options, :error, :base, "Filter data only contain open status records, tat report won't export to only open status records"
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