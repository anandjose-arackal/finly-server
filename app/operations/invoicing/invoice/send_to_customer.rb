class Invoicing::Invoice::SendToCustomer < Invoicing::Invoice::Base

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

    if self.invoice.incomplete?
      add_message :error, "Incomplete invoices cannot be sent to the customer"
      return
    end
  end

  def process
    InvoiceMailer.delay.send_to_customer(self.invoice) # todo - arguments might change
  end

end