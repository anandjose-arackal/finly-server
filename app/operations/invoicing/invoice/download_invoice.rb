class Invoicing::Invoice::DownloadInvoice < Invoicing::Invoice::Base

  attr_accessor :invoice

  def pre_validate
    if user.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    id = params[:id] || params[:outward_invoice_id]
    # user = User.find_by(email: "sreeramnr@finly.io")
    self.invoice = user.company.outward_invoices.non_deleted.find_by(id: id)
  end

  def validate
    if self.invoice.blank?
      add_message :error, "Invoice not found"
      return
    end
  end

  def process

  end

  def success
    params[:invoice] = self.invoice
    Invoicing::Invoice::Base::InvoicePresenter.new(user, params, messages)
  end

end