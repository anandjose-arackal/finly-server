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
    self.invoice = user.company.outward_invoices.build(invoice_status_id: OutwardInvoiceStatus.id_for(:incomplete))
    unless self.invoice.save
      add_message :error, self.invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice successfully created!"
  end

  def success
    params[:invoice] = self.invoice
    Invoicing::Invoice::Base::InvoicePresenter.new(user, params, messages)
  end

end