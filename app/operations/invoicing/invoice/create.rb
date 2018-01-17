class Invoicing::Invoice::Create < Invoicing::Invoice::Base

  attr_accessor :invoice_params, :invoice

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init

  end

  def validate

  end

  def process
    self.invoice = OutwardInvoice.create(invoice_status_id: OutwardInvoiceStatus.id_for(:incomplete))
  end

  def post_process
    add_message :success, "Invoice successfully created!"
  end

end