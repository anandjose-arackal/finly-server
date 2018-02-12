class Invoicing::Invoice::Index < Invoicing::Invoice::Base

  attr_accessor :invoices, :company

  class Invoicing::Invoice::Index::InvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices, :paginated_invoices

    def init
      self.invoices = params[:invoices]
      self.paginated_invoices = invoices.paginate(page: params[:page], per_page: params[:per_page])
    end

  end

  def init
    self.invoices = user.company.outward_invoices.exclude_deleted
  end

  def success
    params[:invoices] = self.invoices
    Invoicing::Invoice::Index::InvoicesPresenter.new(user, params, messages)
  end

end