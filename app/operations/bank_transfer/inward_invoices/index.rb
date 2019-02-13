class BankTransfer::InwardInvoices::Index < BankTransfer::InwardInvoices::Base

  attr_accessor :invoices

  class BankTransfer::InwardInvoices::Index::InwardInvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices, :paginated_invoices

    has_scope :filter_payable_invoices
    has_scope :invoice_date, using: [:from, :to], type: :hash
    has_scope :due_date, using: [:from, :to], type: :hash

    def init
      self.invoices = params[:invoices]
      self.invoices = apply_scopes(self.invoices, params)
      self.paginated_invoices = self.invoices.paginate(page: params[:page], per_page: (params[:per_page] || 30))
    end
  end

  attr_accessor :invoices

  def init
    self.invoices = user.company.inward_invoices.non_beneficiary.created_at_desc
  end

  def success
    params[:invoices] = self.invoices
    BankTransfer::InwardInvoices::Index::InwardInvoicesPresenter.new(user, params, messages)
  end

end