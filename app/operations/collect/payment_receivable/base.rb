class Collect::PaymentReceivable::Base < Collect::Base

  def init_payment_request(purpose, receiving_account)
    initiating_account = self.virtual_account
    initiating_user = self.virtual_account.initiating_user
    payment_request = PaymentRequest.(initiating_user, initiating_account, receiving_account.class.name, :credit, :payment_link_credit)
    payment_request.add_payment_item(PaymentRequest::PaymentItem.(nil, receiving_account, self.virtual_account_transaction.transfer_amount))
    payment_request
  end

  def create_customer

  end

end
