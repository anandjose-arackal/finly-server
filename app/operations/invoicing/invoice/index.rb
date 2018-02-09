class Invoicing::Invoice::Index < Invoicing::Invoice::Base

  attr_accessor :invoices, :company

  class Invoicing::Invoice::Index::InvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices

    def init
      self.invoices = params[:invoices]
    end

  end

  def init
    self.invoices = user.company.outward_invoices
  end

  def success
    params[:invoices] = self.invoices
    Invoicing::Invoice::Index::InvoicesPresenter.new(user, params, messages)
  end

end