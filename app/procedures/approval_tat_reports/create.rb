class ApprovalTatReports::Create < Transactions::API

  user_model [User, AdminUser]

  step :check_feature_flag
  step :find_builder
  pass :resolve
  step :check_open_status_records
  step :run_background_job

  schema do
    params do
      required(:route)
    end
  end

  def check_feature_flag(context, params:, current_user:, **)
    unless ApprovalTatReportsToggle.new(current_user).enabled?
      add_message context, :error, :base, "Tat reports feature is not enabled"
      return false
    end
    true
  end

  def find_builder(context, params:, **)
    route = IndexBuilder::Router[params[:route]]&.first
    unless route.present?
      return on_error context, :route, 'not found'
    end
    
    context[:builder] = route.klass
    true
  end

  def resolve(context, builder:, params:, **)
    builder.resolve(context, paginate: false)
  end

  def check_open_status_records(context, params:, current_user:, **)
    index_result_documents = context['model.records']
    context[:total_documents_count] = index_result_documents&.count
    open_documents_count = 0

    case params.dig(:route).upcase
      when "INVOICES"
        open_documents_count = index_result_documents.where(invoice_status_id: InwardInvoiceStatus.id_for(:open))&.ids&.count
      when "PURCHASE_REQUESTS"
        open_documents_count = index_result_documents.where(purchase_request_status_id: PurchaseRequestStatus.id_for(:draft))&.ids&.count
      when "PURCHASE_ORDERS"
        open_documents_count = index_result_documents.where(purchase_order_status_id: PurchaseOrderStatus.id_for(:open))&.ids&.count
      when "PAYMENT_TICKETS"
        open_documents_count = index_result_documents.where(status_id: BankPaymentRequestStatus.id_for(:open))&.ids&.count
      when  "AGREEMENTS"
        open_documents_count = index_result_documents.where(status_id: PaymentAgreementStatus.id_for(:draft))&.ids&.count
      when "UTILITY_SUBSCRIPTIONS"
        open_documents_count = index_result_documents.where(status_id: BbpsBillerSubscriptionStatus.id_for(:draft))&.ids&.count
      when "VENDORS"
        open_documents_count = index_result_documents.where(status_id: VendorStatus.id_for(:draft))&.ids&.count
    end

    if context[:total_documents_count] == open_documents_count
      add_message context, :error, :base, "Open Status transaction cannot be exported in the TAT report, please choose a different filter and try again."
      return false
    end

    context[:actual_export_count] = context[:total_documents_count] - open_documents_count

    true
  end

  def run_background_job(context, params:, current_user:,total_documents_count:, actual_export_count:, **)
    add_message context, :success, :base, "You will receive an email on completion of the export with an attachment containing data. Transactions with Open Status will not be included in the TAT report. You will receive the email in approximately #{actual_export_count < 5000 ? 5 : 10} minutes."
    optimize_tat_report = ApprovalTatReportsOptimizeToggle.new(current_user).enabled?
    job_log_object = ApprovalTatReportExecLog.create(company_id: current_user&.company_id, 
                                              user_id: current_user&.id,
                                              document_type: params.dig(:route),
                                              record_count: total_documents_count,
                                              output_count: actual_export_count,
                                              start_time: DateTime.now,
                                              filter_json: params["q"]
                                            )
    ApprovalTatReports::TatExport.call_async(params: params, current_user: current_user, optimize_tat_report: optimize_tat_report, job_log_object: job_log_object)
    true
  end

end