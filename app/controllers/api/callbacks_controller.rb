class Api::CallbacksController < BaseControllers::ApiBase

  protect_from_forgery with: :null_session


  def successful_vendor_payment
    body = {
        payment_id: (params[:payment_id] || Payment.last.id),
        payment_amount: (params[:payment_amount] || Payment.last.amount_value),
        note: (params[:note] || Payment.last.note),
        status: (params[:status] || Payment.last.payment_status&.name),
        receiving_account: {
            receiving_account_type: (params&.dig(:receiving_account,:receiving_account_type) || Payment.last.receiving_account_type),
            receiving_account_id: (params&.dig(:receiving_account,:receiving_account_id) || Payment.last.receiving_account_id),
            receiving_account_number: (params&.dig(:receiving_account, :account_number) || "1122334455"),
            receiving_account_ifsc: (params&.dig(:receiving_account, :account_number) || "IFSC1122334")
        }
    }
    company = current_user.company
    @result = Webhook::Process.(nil, {company: company, body: body, web_hook_event_id: WebHookEvent.id_for('vendor_payments.credit_confirmation')})
    respond_success_failure
  end

  def invoice_payment_received

  end
end
