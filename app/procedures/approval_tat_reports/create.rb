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
    open_documents_count = 0

    case params.dig(:route).upcase
      when "INVOICES"
        open_documents_count = index_result_documents.where(invoice_status_id: InwardInvoiceStatus.id_for(:open))&.count
      when "PURCHASE_REQUESTS"
        open_documents_count = index_result_documents.where(purchase_request_status_id: PurchaseRequestStatus.id_for(:draft))&.count
      when "PURCHASE_ORDERS"
        open_documents_count = index_result_documents.where(purchase_order_status_id: PurchaseOrderStatus.id_for(:open))&.count
      when "PAYMENT_TICKETS"
        open_documents_count = index_result_documents.where(status_id: BankPaymentRequestStatus.id_for(:open))&.count
      when  "AGREEMENTS"
        open_documents_count = index_result_documents.where(status_id: PaymentAgreementStatus.id_for(:draft))&.count
      when "UTILITY_SUBSCRIPTIONS"
        open_documents_count = index_result_documents.where(status_id: BbpsBillerSubscriptionStatus.id_for(:draft))&.count
      when "VENDORS"
        open_documents_count = index_result_documents.where(status_id: VendorStatus.id_for(:draft))&.count
    end

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