class AccountManager::Collect::Invoice::Accept < AccountManager::Collect::Invoice::Base

  attr_accessor :virtual_account, :company, :outward_invoices, :payment, :virtual_account_transaction,
                :amount_due, :transaction_amount

  def init
    self.virtual_account_transaction = params[:virtual_account_transaction]
    self.virtual_account = virtual_account_transaction.virtual_account
    self.transaction_amount = self.virtual_account_transaction.transfer_amount.to_f
    self.company = virtual_account.company
    self.outward_invoices = self.virtual_account.outward_invoices.payments_receivable
    self.amount_due = self.outward_invoices.joins(:balance_due).sum(:value) - self.outward_invoices.joins(:paid_amount).sum(:value)
  end

  def validate
    unless self.outward_invoices.present?
      add_message :error, "Invoice not found"
      return
    end

    if self.amount_due <=0
      add_message :error, "Amount due is negative for invoices with this account number"
      return
    end

    # # ensure that the invoice is still in an unpaid state
    # unless OutwardInvoiceStatus.ids_for(:unpaid, :partially_paid, :saved, :sent_to_customer).include?(self.outward_invoice.invoice_status_id)
    #   add_message :error, "Only unpaid or partially paid invoices can accept payments"
    #   return
    # end
  end

  def process
    # FIFO for all the invoices
    remaining_amount = self.transaction_amount
    self.outward_invoices.each do |invoice|
      due_amount = invoice.balance_due&.value - invoice.paid_amount&.value
      if remaining_amount < due_amount
        paid_amount = invoice.paid_amount&.value + self.transaction_amount
        invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:partially_paid), paid_amount_attributes: {id: invoice.paid_amount.id, value: paid_amount})
      elsif remaining_amount >= due_amount
        invoice.paid_amount.update(value: invoice.balance_due.value)
        remaining_amount = remaining_amount - due_amount
      end
      if remaining_amount <= 0
        break
      end
    end
    # if there's still any amount remaining in remaining_amount, add it to the last invoice's paid amount
    if remaining_amount > 0
      last_invoice = self.outward_invoice.reorder(created_at: :desc).first
      paid_amount = last_invoice.paid_amount.value
      last_invoice.paid_amount.update(value: (paid_amount + remaining_amount))
    end
    # # update the amount paid for this particular invoice, and status accordingly
    # if self.virtual_account_transaction.transfer_amount&.to_f >= self.amount_due
    #   amount_paid = self.outward_invoice.paid_amount&.value.to_f + self.virtual_account_transaction.transfer_amount&.to_f
    #   self.outward_invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:closed))
    #   self.outward_invoice.paid_amount.update(value: amount_paid)
    # elsif self.virtual_account_transaction.transfer_amount&.to_f < self.amount_due
    #   amount_paid = self.outward_invoice.paid_amount&.value.to_f + self.virtual_account_transaction.transfer_amount&.to_f
    #   self.outward_invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:partially_paid))
    #   self.outward_invoice.paid_amount&.update(value: amount_paid)
    # end
  end

  def post_process
    # mailers and shit
  end


end