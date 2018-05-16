class BankTransfer::InwardInvoices::Show < BankTransfer::InwardInvoices::Base

  attr_accessor :inward_invoice

  class BankTransfer::InwardInvoices::Show::InvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice

    def init
      self.invoice = params[:inward_invoice]
    end

  end

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