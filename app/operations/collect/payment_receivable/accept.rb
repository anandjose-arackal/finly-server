class Collect::PaymentReceivable::Accept < Collect::PaymentReceivable::Base

  attr_accessor :virtual_account, :company, :payment_receivable, :payment_request,
                :trail, :payment

  def init
    # id = params[:id] || params[:virtual_account_transaction_id]
    # self.virtual_account_transaction = ::VirtualAccountTransaction.find_by(id: id)
    self.virtual_account = virtual_account_transaction.virtual_account
    self.company = virtual_account.company
    self.trail = ::VirtualAccountCollectTrail.find_by(id: options[:trail_id])
    self.payment_request = init_payment_request(:virtual_bank_account, self.virtual_account.receiving_account)
    self.payment_receivable = self.virtual_account.parent
  end

  def validate
    if self.payment_receivable.blank?
      add_message :error, "Payment Request not found"
    end
  end

  def process
    # triggering the operation for creating the payment
    op = AccountManager::Payments::PaymentProcessor.(self.virtual_account.initiating_user, payment_request: self.payment_request)
    if op.success?
      payment = op.payment_order.payments.first
      self.payment.update(reference_resource: self.virtual_account_transaction)
      self.payment_receivable.update(payment: payment)
      self.trail.update(update_company_balance: true, creating_payment: true)
    end
  end

  def post_process
    # mark the payment receivable as paid
    if self.payment_receivable.update(payment_receivable_status_id: PaymentReceivableStatus.id_for(:received))
      self.trail.update(payment_receivable_updation: true)
    end
    # trigger mailers if necessary
  end

  def success

  end

  def failure
    self.trail.update(note: self.messages[:error].to_sentence, update_company_balance: false, creating_payment: false)
  end
end