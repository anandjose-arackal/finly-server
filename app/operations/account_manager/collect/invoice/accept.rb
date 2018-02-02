class AccountManager::Collect::Invoice::Accept < AccountManager::Collect::Invoice::Base

  attr_accessor :virtual_account, :company, :outward_invoice, :payment, :virtual_account_transaction,
                :amount_due

  def init
    self.virtual_account_transaction = params[:virtual_account_transaction]
    self.virtual_account = virtual_account_transaction.virtual_account
    self.company = virtual_account.company
    self.outward_invoice = self.virtual_account.parent
    self.amount_due = self.outward_invoice.balance_due&.value.to_f - self.outward_invoice.paid_amount&.value.to_f
  end

  def validate
    # ensure that the invoice is still in an unpaid state
    unless self.outward_invoice.unpaid? || self.outward_invoice.partially_paid?
      add_message :error, "Only unpaid or partially paid invoices can accept payments"
      return
    end

  end

  def process
    # update the amount paid for this particular invoice, and status accordingly
    if self.virtual_account_transaction.transfer_amount&.to_f >= self.amount_due
      amount_paid = self.outward_invoice.paid_amount&.value.to_f + self.virtual_account_transaction.transfer_amount&.to_f
      self.outward_invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:closed))
      self.outward_invoice.paid_amount.update(value: amount_paid)
    elsif self.virtual_account_transaction.transfer_amount&.to_f < self.amount_due
      amount_paid = self.outward_invoice.paid_amount&.value.to_f + self.virtual_account_transaction.transfer_amount&.to_f
      self.outward_invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:partially_paid))
      self.outward_invoice.paid_amount.update(value: amount_paid)
    end
  end

  def post_process
    # mailers and shit
  end


end