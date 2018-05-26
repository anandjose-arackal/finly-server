# this oepration adds an invoice to a payment order and picks up details
# for the payment from there
class BankTransfer::PaymentRequest::InwardInvoice::Add < BankTransfer::PaymentRequest::Base

  attr_accessor :inward_invoices

  def init
    ids = params[:invoice_ids]
    unless ids.is_a?(Array)
      ids = params[:invoice_ids].split(",")
    end
    self.inward_invoices = user.company.inward_invoices.with_id(ids)
    bank_payment_request_id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.find_by(id: bank_payment_request_id)
  end

  def validate
    if self.bank_payment_request.blank?
      add_message :error, "Payment ticket not found"
      return
    end

    if self.inward_invoices.empty?
      add_message :error, "Nothing to add"
      return
    end
  end
end