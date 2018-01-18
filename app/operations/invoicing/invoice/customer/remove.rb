class Invoicing::Invoice::Customer::Remove < Invoicing::Invoice::Base


  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:outward_invoice_id]
    self.invoice = self.user.company.outward_invoices.find_by(id: invoice_id)
  end

  def validate
    if self.invoice.blank?
      add_message :error,"Invoice not found"
      return
    end

    unless self.invoice.editable?
      add_message :error, "Invoice cannot be changed in this state"
    end
  end

  def process
    # update the customer as nil for this particular invoice
    unless self.invoice.update(customer_id: nil, billing_address: nil, shipping_address: nil)
      add_message :error, self.invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Customer removed"
  end
end