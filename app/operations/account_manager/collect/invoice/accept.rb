class AccountManager::Collect::Invoice::Accept < AccountManager::Collect::Invoice::Base

  attr_accessor :virtual_account, :company, :outward_invoices, :payment, :virtual_account_transaction,
                :amount_due, :transaction_amount, :affected_outward_invoices, :customer, :customer_account

  def init
    self.virtual_account_transaction = params[:virtual_account_transaction]
    self.virtual_account = virtual_account_transaction.virtual_account
    self.customer = virtual_account.customer
    self.customer_account = self.customer.customer_account #todo add validations for existence
    self.company = virtual_account.company
    self.outward_invoices = self.virtual_account.outward_invoices.tax_invoices.payments_receivable.reorder(created_at: :asc)
    self.transaction_amount = self.virtual_account_transaction.transfer_amount.to_f
    self.amount_due = self.outward_invoices.joins(:balance_due).sum(:value) - self.outward_invoices.joins(:paid_amount).sum(:value)

    # To store all the newly credited invoices
    self.affected_outward_invoices = []
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
    # todo-abi create invoice trail
    # FIFO for all the invoices
    remaining_amount = self.transaction_amount
    last_invoice = self.outward_invoices.first
    self.outward_invoices.each do |invoice|
      due_amount = invoice.balance_due&.value
      if remaining_amount < due_amount
        # When transfer amount is less than invoice's balance due
        new_paid_amount = invoice.paid_amount&.value + remaining_amount
        balance_due = invoice.balance_due&.value - remaining_amount
        if invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:partially_paid),
                       paid_amount_attributes: {id: invoice.paid_amount.id, value: new_paid_amount},
                       balance_due_attributes: {id: invoice.balance_due.id, value: balance_due})
          trail = invoice.invoice_trails.new({
                                            action_id: OutwardInvoiceTrailAction.id_for(:credit_virtual_account),
                                            associated_transaction: virtual_account_transaction,
                                            date: virtual_account_transaction.created_at.strftime("%d-%b-%Y"),
                                            amount_attributes: {
                                                value: remaining_amount,
                                                currency_id: Currency.id_for(virtual_account_transaction.transfer_currency)
                                            }
                                        })
          trail.save
        end
        affected_invoice_data = {invoice: invoice, amount: remaining_amount}
        remaining_amount = 0
      elsif remaining_amount >= due_amount
        invoice.paid_amount.update(value: (invoice.net_amount&.value + invoice.roundoff_amount)) # i.e. setting the paid amount as the total of what was supposed to be paid for this invoice
        invoice.balance_due.update(value: 0)
        invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:paid))
        # create trail
        trail = invoice.invoice_trails.new({
                                            action_id: OutwardInvoiceTrailAction.id_for(:credit_virtual_account),
                                            associated_transaction: virtual_account_transaction,
                                            date: virtual_account_transaction.created_at.strftime("%d-%b-%Y"),
                                            amount_attributes: {
                                                value: due_amount,
                                                currency_id: Currency.id_for(virtual_account_transaction.transfer_currency)
                                            }
                                        })
        trail.save
        remaining_amount = remaining_amount - due_amount
        affected_invoice_data = {invoice: invoice, amount: due_amount}
      end

      self.affected_outward_invoices << affected_invoice_data
      # associating the particular invoice and virtual account transaction ID for the mapping
      InvoiceTransactionMapping.create(invoice_id: invoice.id, va_transaction_id: self.virtual_account_transaction.id)
      last_invoice = invoice # setting this as the last invoice that was processed
      if remaining_amount <= 0
        break
      end
    end
    # if there's still any amount remaining in remaining_amount, add it to the last invoice's paid amount - Step 1
    if remaining_amount > 0
      params = {
          virtual_account_transaction: self.virtual_account_transaction,
          type: 'virtual_account_to_customer_account',
          amount: remaining_amount
      }
      # Add Remaining amount to Customer's account
      op = AccountManager::Collect::CustomerAccount::Transfer.(nil, params)
      if op.failure?
        #todo uncomment it before deploy
        # Event::EAlert::Create.(nil, title: 'Finly Collect - Failed to Add Money to Customer Account',description: "#{self.virtual_account_transaction.as_json}", subject: 'Finly Collect - Failed to Add Money to Customer Account')
      end
      # remove code when version invoicing version 2.1 has been deployed
      # paid_amount = last_invoice.paid_amount.value
      # last_invoice.paid_amount.update(value: (paid_amount + remaining_amount))
      # unless self.virtual_account_transaction.invoices.include?(last_invoice)
      #   InvoiceTransactionMapping.create(invoice_id: last_invoice.id, va_transaction_id: self.virtual_account_transaction.id)
      # end
      # # Also update the last invoice in affected_outward_invoices, and add the remaining amount to the amount received - Step 2 & Final
      # for affected_invoice_data in affected_outward_invoices
      #   if affected_invoice_data[:invoice].id == last_invoice.id
      #     affected_invoice_data[:amount] = affected_invoice_data[:amount] + remaining_amount
      #   end
      # end
    end


    # end
  end

  def post_process
    # mailers and shit
    self.affected_outward_invoices.each do |invoice_data|
      Event::EOutwardInvoice::PaymentNotify.(nil, {invoice_data: invoice_data})
    end
  end


end