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
    index_result_documents = index_result['model.records']
    total_documents_count = index_result_documents&.count
    exclude_open_documents_count = 0

      case params.dig(:route).upcase
        when "INVOICES" || "PURCHASE_ORDERS" || "PAYMENT_TICKETS"
          exclude_open_documents_count = index_result_documents.not_open.count
        when "PURCHASE_REQUESTS" || "AGREEMENTS"
          exclude_open_documents_count = index_result_documents.not_draft.count
        when "VENDORS"
          exclude_open_documents_count = index_result_documents.non_draft.count
        when "UTILITY_SUBSCRIPTIONS"
          exclude_open_documents_count = index_result_documents.where.not(status_id: BbpsBillerSubscriptionStatus.id_for(:draft)).count
      end


    open_documents_count = total_documents_count - exclude_open_documents_count

    if total_documents_count == open_documents_count
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