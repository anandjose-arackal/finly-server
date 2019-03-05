class BankTransfer::InwardInvoices::Index < BankTransfer::InwardInvoices::Base

  attr_accessor :invoices

  class BankTransfer::InwardInvoices::Index::InwardInvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices, :paginated_invoices

    has_scope :filter_payable_invoices
    has_scope :invoice_date, using: [:from, :to], type: :hash
    has_scope :due_date, using: [:from, :to], type: :hash
    has_scope :filter_invoice_number
    has_scope :filter_by_created_at
    has_scope :filter_vendor_id
    has_scope :filter_po_invoice
    has_scope :filter_non_po_invoice
    has_scope :filter_status
    has_scope :filter_invoice_type
    has_scope :filter_po_number

    def init
      self.invoices = params[:invoices]
      self.invoices = apply_scopes(self.invoices, params)
      self.paginated_invoices = self.invoices.paginate(page: params[:page], per_page: (params[:per_page] || 30))
    end

    def po_invoice_status_count
      get_count(1)
    end

    def non_po_invoice_status_count
      get_count(3)
    end

    def get_count(id)
      raw_count = self.invoices.where(invoice_type_id: id).group( :invoice_status_id).count
      h = {}
      InwardInvoiceStatus.all.each {|ps| if raw_count.keys.include? ps.id then h[ps.name] = raw_count[ps.id] else h[ps.name] = 0 end}
      return h
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