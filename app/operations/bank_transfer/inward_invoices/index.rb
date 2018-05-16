class BankTransfer::InwardInvoices::Index < BankTransfer::InwardInvoices::Base

  attr_accessor :invoices

  class BankTransfer::InwardInvoices::Index::InwardInvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices

    def init
      self.invoices = params[:invoices]
    end
  end

  attr_accessor :invoices

  def init
    self.invoices = user.company.inward_invoices
  end

  def success
    params[:invoice] = self.invoices
    BankTransfer::InwardInvoices::Index::InwardInvoicesPresenter.new(user, params, messages)
  end

end