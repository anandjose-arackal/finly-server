class Invoicing::Invoice::Public::Show < Invoicing::Invoice::Base

  attr_accessor :invoice

  def pre_validate

  end

  def init
    id = params[:id] || params[:invoice_id]
    self.invoice = OutwardInvoice.find_by(id: id)
  end

  def success
    params[:invoice] = self.invoice
    params[:invoice_number] = self.invoice.invoice_number
    Invoicing::Invoice::Base::InvoicePresenter.new(user, params, messages)
  end
end