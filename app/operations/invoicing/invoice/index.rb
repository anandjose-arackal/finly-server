class Invoicing::Invoice::Index < Invoicing::Invoice::Base

  attr_accessor :invoices, :company

  class Invoicing::Invoice::Index::InvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices, :paginated_invoices

    has_scope :filter_amount, using: [:type, :value], type: :hash
    has_scope :filter_date, using: [:date_from, :date_to], type: :hash
    has_scope :filter_search
    has_scope :filter_status_id, type: :array
    has_scope :filter_customer_id
    has_scope :filter_invoice_number

    def init
      self.invoices = params[:invoices]
      self.invoices = apply_scopes(self.invoices, params)
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