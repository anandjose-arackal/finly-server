class Invoicing::Invoice::Cancel < Invoicing::Invoice::Base

  attr_accessor :invoice

  def init
    id = params[:id] || params[:outward_invoice_id]
    self.invoice = user.company.outward_invoices.find_by(id: id)
  end

  def validate

    unless self.invoice.present?
      add_message :error, "Invoice not found"
      return
    end

    unless self.invoice.saved? || self.invoice.sent_to_customer?
      add_message :error, "Only saved invoices can be cancelled"
      return
    end
  end

  def process
    unless self.invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:cancelled))
      add_message :error, self.invoice.errors.full_messages
    end
  end

  def post_process
    # todo - notification / mailer to Customer regarding cancellation?
    add_message :success, "Invoice cancelled"
  end
end