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
      add_message options, :error, :base, "Open Status transaction cannot be exported in the TAT report, please choose a different filter and try again."
      return false
    end
    true
  end

  def run_background_job(options, params:, current_user:, **)
    add_message options, :success, :base, "You will receive an email on completion of the export with an attachment containing data. Transactions with Open Status will not be included in the TAT report."
    ApprovalTatReports::TatExport.call_async(params: params, current_user: current_user)
    true
  end

end