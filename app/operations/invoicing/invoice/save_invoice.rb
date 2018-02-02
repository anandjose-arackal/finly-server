# this checks the invoice for all validations and eventually saves the invoice which can now be sent to the customer
class Invoicing::Invoice::SaveInvoice < Invoicing::Invoice::Base

  attr_accessor :invoice

  def init
    id = params[:id] || params[:outward_invoice]
    self.invoice = user.company.outward_invoices.find_by(id: id)
  end

  def validate
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
    unless self.invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:saved))
      add_message :error, self.invoice.errors.full_messages
      return
    end
  end

  def post_process
    add_message :error, "Invoice successfully created!"
  end
end