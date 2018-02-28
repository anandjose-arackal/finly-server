class Invoicing::Invoice::SendToCustomer < Invoicing::Invoice::Base

  attr_accessor :invoices

  def init
    ids = params[:id] || params[:outward_invoice_ids] || params[:outward_invoice_id]
    self.invoices = user.company.outward_invoices.with_id(ids)
  end

  def validate
    if self.invoices.empty?
      add_message :error, "Invoices not found"
      return
    end

    spurious_ids = []
    self.invoices.each do |invoice|
      if invoice.incomplete?
        spurious_ids << invoice.invoice_number
      end
    end
    unless spurious_ids.empty?
      add_message :error, "Incomplete invoices cannot be sent to customers. The following invoices are incomplete: #{spurious_ids.to_sentence}"
      return
    end
  end

  def process
    self.invoices.each do |invoice|
      InvoiceMailer.delay.send_to_customer(invoice)
    end
  end

  def post_process
    add_message :success, "Invoice successfully sent!"
  end

end