# this checks the invoice for all validations and eventually saves the invoice which can now be sent to the customer
class Invoicing::Invoice::SaveInvoice < Invoicing::Invoice::Base

  attr_accessor :invoice

  def init
    id = params[:id] || params[:outward_invoice_id]
    self.invoice = user.company.outward_invoices.find_by(id: id)
  end

  def validate
    if self.invoice.blank?
      add_message :error, "Invoice not found"
      return
    end

    unless self.invoice.incomplete?
      add_message :error, "Invoice cannot be created in this state"
      return
    end

    self.invoice.invoice_status_id = OutwardInvoiceStatus.id_for(:saved)
    unless self.invoice.valid?
      add_message :error, self.invoice.errors.full_messages
      return
    end
  end

  def process
    if self.invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:saved))
      self.invoice.update(paid_amount: Amount.create(value: 0, currency_id: 1)) # setting the paid amount as 0 at the time of saving
    else
      add_message :error, self.invoice.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Invoice successfully created!"
  end
end