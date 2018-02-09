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

    # if self.amount_due <=0
    #   add_message :error, "Amount due is negative for invoices with this account number"
    #   return
    # end

  end

  def process
    # FIFO for all the invoices
    remaining_amount = self.transaction_amount
    last_invoice = self.outward_invoices.first
    self.outward_invoices.each do |invoice|
      due_amount = invoice.balance_due&.value
      if remaining_amount < due_amount
        new_paid_amount = invoice.paid_amount&.value + remaining_amount
        balance_due = invoice.balance_due&.value - remaining_amount
        invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:partially_paid),
                       paid_amount_attributes: {id: invoice.paid_amount.id, value: new_paid_amount},
                       balance_due_attributes: {id: invoice.balance_due.id, value: balance_due})
        remaining_amount = 0
      elsif remaining_amount >= due_amount
        invoice.paid_amount.update(value: (invoice.net_amount&.value + invoice.roundoff_amount)) # i.e. setting the paid amount as the total of what was supposed to be paid for this invoice
        invoice.balance_due.update(value: 0)
        invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:closed))
        remaining_amount = remaining_amount - due_amount
      end
      last_invoice = invoice # setting this as the last invoice that was processed
      if remaining_amount <= 0
        break
      end
    end
    # if there's still any amount remaining in remaining_amount, add it to the last invoice's paid amount
    if remaining_amount > 0
      paid_amount = last_invoice.paid_amount.value
      last_invoice.paid_amount.update(value: (paid_amount + remaining_amount))
    end
    # end
  end

  def post_process
    # mailers and shit
  end


end