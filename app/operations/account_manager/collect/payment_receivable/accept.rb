class AccountManager::Collect::PaymentReceivable::Accept < AccountManager::Collect::PaymentReceivable::Base

  attr_accessor :virtual_account, :company, :payment_receivable, :payment

  def init
    self.virtual_account_transaction = params[:virtual_account_transaction]
    self.virtual_account = virtual_account_transaction.virtual_account
    self.company = virtual_account.company
    self.payment_receivable = self.virtual_account.parent
  end

  def validate
    if self.payment_receivable.blank?
      add_message :error, "Payment Request not found"
      return
    end

    if payment_receivable.received?
      add_message :error, "Payment already received. Please activate the payment link again to receive payments"
      return
    end

    # check for the exact amount match in the payment receivable
    unless payment_receivable.amount_value == self.virtual_account_transaction.transfer_amount.to_f
      add_message :error, 'The amount credited does not match the payment link amount'
    end
  end

  def process
    # mark the payment receivable as paid
    self.payment_receivable.update(payment_receivable_status_id: PaymentReceivableStatus.id_for(:received))
  end

end