class Invoicing::Invoice::MarkAsClosed < Invoicing::Invoice::Base

  attr_accessor :invoice, :paid_amount
  # not being used

  def init
    id = params[:id] || params[:outward_invoice_id]
    self.invoice = user.company.outward_invoices.find_by(id: id)
    self.paid_amount = params[:paid_amount]
  end

  def validate
    if self.invoice.blank?
      add_message :error, "Invoice not found"
      return
    end

    if self.paid_amount.to_f < 0
      add_message :error, "Paid amount cannot be negative"
      return
    end
  end

  def process
    if self.invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:paid))
      balance_due = (self.invoice.total_payable&.value - self.paid_amount.to_f) > 0 ? (self.invoice.total_payable&.value - self.paid_amount.to_f) : 0
      self.invoice.balance_due.update(value: balance_due)
      self.invoice.paid_amount.update(value: self.paid_amount)
    else
      add_message :error, self.invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice marked as paid"
  end

end