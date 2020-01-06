class BankTransfer::PaymentRequest::Progress < BankTransfer::PaymentRequest::Base

  attr_accessor :bank_payment_request

  def init
    id = params[:id] || params[:payment_request_id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankPaymentRequest.find_by_id id
  end

  def validate
    # Check of bank_payment_request exists
    return if record_not_present
    # Validate if user is associated with the bank_payment_request
    validate_document_access
  end

  def process

  end

  def success
    # payment_requests_count
    params[:expected_payments] = self.bank_payment_request.expected_payments
    params[:actual_payments] = self.bank_payment_request.payment_order.payments.count
    params[:status] = self.bank_payment_request.status.name
    BankTransfer::PaymentRequest::PorgressPresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::PorgressPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :expected_payments, :actual_payments, :status

    def init
      self.expected_payments = params[:expected_payments]
      self.actual_payments = params[:actual_payments]
      self.status = params[:status]
    end
  end

  private

  def validate_presence
    if bank_payment_request.blank? || (bank_payment_request.company_id != user.company_id)
      add_message :error, "Payment ticket not found!"
      return false
    end
    true
  end

  def record_not_present
    !validate_presence
  end

  def validate_document_access
    # Owner of document is allowed to access the bank_payment_request, no further validation required
    return if bank_payment_request.validate_if_owner(user)
    return if bank_payment_request.validate_if_admin(user) && (!bank_payment_request.open? || (bank_payment_request.owner_id == user.id) || bank_payment_request.owner_id.blank?)
    return if bank_payment_request.validate_if_reviewer(user)
    return if bank_payment_request.validate_if_creditor(user)
    return if bank_payment_request.validate_if_auditor(user)
    raise_unauthorized_exception
  end
end