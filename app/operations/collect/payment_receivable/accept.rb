class Collect::PaymentReceivable::Accept < Collect::PaymentReceivable::Base

  attr_accessor :virtual_account, :company, :payment_receivable

  def init
    self.virtual_account = virtual_account_transaction.virtual_bank_account
    self.company = virtual_account.company
    self.payment_request = init_payment_request(:virtual_bank_account, company)
    self.payment_receivable = self.virtual_account.parent
  end

  def process
    # triggering the operation for creating the payment
    op = AccountManager::Payments::PaymentProcessor.(self.virtual_account.initiating_user, payment_request: self.payment_request)
    if op.success?
      payment = op.payment_order.payments.first
      self.payment_receivable.update(payment: payment)
    end
  end

  def post_process
    # mark the payment receivable as paid

    # trigger mailers if necessary

  end
end