class BankTransfer::InwardInvoices::Destroy < BankTransfer::InwardInvoices::Base

  attr_accessor :inward_invoice

  def init
    id = params[:id] || params[:inward_invoice_id]
    self.inward_invoice = user.company.inward_invoices.find_by(id: id)
  end

  def validate
    if self.inward_invoice.blank?
      add_message :error, "Invoice not found"
      return
    end

    # ensuring that the inward invoice is unpaid, and doesn't
    # have any other payments associated with it
    unless self.inward_invoice.unpaid?
      add_message :error, "Only unpaid invoices can be deleted"
      return
    end

    # if the invoice has payments attached to it, it cannot be destroyed
    if self.inward_invoice.payments.present?
      add_message :error, "This invoice has payments attached to it, and cannot be destroyed"
      return
    end
  end

  def process
    unless self.inward_invoice.destroy
      add_message :error, self.inward_invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice destroyed"
  end

end