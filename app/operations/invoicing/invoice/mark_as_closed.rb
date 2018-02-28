class Invoicing::Invoice::MarkAsClosed < Invoicing::Invoice::Base

  attr_accessor :invoice

  def init
    id = params[:id] || params[:outward_invoice_id]
    self.invoice = user.company.outward_invoices.find_by(id: id)
  end

  def validate
    if self.invoice.blank?
      add_message :error, "Invoice not found"
    end
  end

  def process
    unless self.invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:closed))
      # todo - should balance due also be set to zero?
      add_message :error, self.invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice marked as closed"
  end

end