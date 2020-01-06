class Streamsets::Transactions::Payments < BaseOperation

  def pre_validate

  end

  def init
    op = BankTransfer::PaymentRequest::Index.(user, params)
    if op.failure?
      add_message :error, op.messages[:error]
      return
    end

	  bank_payment_requests = op.payment_requests.where(ticket_type: 'invoice')

  end

end