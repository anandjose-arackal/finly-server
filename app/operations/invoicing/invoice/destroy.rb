class Invoicing::Invoice::Destroy < Invoicing::Invoice::Base

  attr_accessor :invoice

  def init
    id = params[:id] || params[:outward_invoice]
    self.invoice = user.company.outward_invoices.find_by(id: id)
  end

  def validate
    unless self.invoice.present?
      add_message :error, "Invoice not found"
      return
    end

    unless self.invoice.incomplete?
      add_message :error, "Invoice cannot be destroyed after neing saved"
    end
  end

  def process
    unless self.invoice.destroy
      add_message :error, self.invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice destroyed!"
  end

end