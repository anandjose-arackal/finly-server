class BankTransfer::InwardInvoices::Show < BankTransfer::InwardInvoices::Base

  attr_accessor :inward_invoice

  def init
    id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.inward_invoice = user.company.inward_invoices.find_by(id: id)
  end

  def validate
    if self.inward_invoice.blank?
      add_message :error, "Invoice not found"
    end
  end

  def success
    params[:inward_invoice] = self.inward_invoice
    BankTransfer::InwardInvoices::Show::InvoicePresenter.new(user, params, messages)
  end
end