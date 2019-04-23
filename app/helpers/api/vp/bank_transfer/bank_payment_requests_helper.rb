module Api::Vp::BankTransfer::BankPaymentRequestsHelper


  def reformat_params
    payment_order_attributes = params[:payment_order]
    params.delete(:payment_order)
    payments_attributes = []
    payment_order_attributes.each do |key, value|
      payments_hash = {
        name: value[:order_name],
        bank_account_name: value[:name],
        bank_account_number: value[:bank_account_number],
        ifsc: value[:ifsc],
        bank_account_id: value[:account_id],
        note: value[:note],
        invoice_number: value[:invoice_number],
        invoice_date: value[:invoice_date],
        invoice_due_date: value[:due_date],
        original_amount: value[:original_amount],
        tds_slab_id: value[:tds_slab_id],
        external_reference_id: value[:external_reference_id]
      }
      payments_attributes << payments_hash
    end
    params[:bank_payment_request] = {
        description: params[:description],
        policy_id: params[:policy_id]
    }
    params[:ticket_type] = "beneficiary"
  end
end