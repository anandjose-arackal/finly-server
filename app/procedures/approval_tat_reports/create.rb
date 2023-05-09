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
    params[:paginate] = false
    result = IndexBuilder::Show.(params: params, current_user: current_user)
    case params.dig(:route).upcase
    when "INVOICES"
      result = result['model.records'].where.not(invoice_status_id: InwardInvoiceStatus.id_for(:open))
    when "PURCHASE_REQUESTS"
      result = result['model.records'].where.not(purchase_request_status_id: PurchaseRequestStatus.id_for(:draft))
    when "PURCHASE_ORDERS"
      result = result['model.records'].where.not(purchase_order_status_id: PurchaseOrderStatus.id_for(:open))
    when "PAYMENT_TICKETS"
      result = result['model.records'].where.not(status_id: BankPaymentRequestStatus.id_for(:open))
    when "AGREEMENTS"
      result = result['model.records'].where.not(status_id: PaymentAgreementStatus.id_for(:draft))
    when "UTILITY_SUBSCRIPTIONS"
      result = result['model.records'].where.not(status_id: BbpsBillerSubscriptionStatus.id_for(:draft))
    when "VENDORS"
      result = result['model.records'].where.not(status_id: VendorStatus.id_for(:draft))
    end

    if result.empty?
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