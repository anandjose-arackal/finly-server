class BankTransfer::InwardInvoices::Payments::Index < BankTransfer::InwardInvoices::Base

  attr_accessor :payments, :inward_invoice

  class BankTransfer::InwardInvoices::Payments::Index::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payments

    def init
      self.payments = params[:payments]
    end
  end

  def init
    id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.inward_invoice = user.company.inward_invoices.find_by(id: id)
  end

  def validate
    if self.inward_invoice.blank?
      add_message :error, "Invoice not found"
      return
    end
  end

  def process
    self.payments = self.inward_invoice.payments
  end

  def success
    params[:payments] = self.payments
    BankTransfer::InwardInvoices::Payments::Index::PaymentsPresenter.new(user, params, messages)
  end

end