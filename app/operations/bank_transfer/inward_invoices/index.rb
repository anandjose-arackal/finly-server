class BankTransfer::InwardInvoices::Index < BankTransfer::InwardInvoices::Base

  class BankTransfer::InwardInvoices::Index::InwardInvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices

    def init
      self.invoices = params[:invoices]
    end
  end

  attr_accessor :invoices

  def init
    self.invoices = user.company.invoices
  end

end