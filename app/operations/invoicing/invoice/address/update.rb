class Invoicing::Invoice::Address::Update < Invoicing::Invoice::Base

  attr_accessor :invoice

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:outward_invoice_id]
    self.invoice = user.company.outward_invoices.find_by(id: invoice_id)
  end

  def validate
    if self.invoice.blank?
      add_message :error, "Invoice not found"
    end
  end

  def process
    unless self.invoice.update(invoice_params)
      add_message :error, self.invoice.errors.full_messages
    end
  end

  def pos_process
    add_message :success, "Address updated successfully"
  end

  private

  def invoice_params
    params.require(:invoice).permit(:billing_address_id, :shipping_address_id)
  end
end
