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
    has_scope :filter_user
    has_scope :filter_year
    has_scope :filter_month

    def init
      self.invoices = params[:invoices]
      self.invoices = apply_scopes(self.invoices, params)
      self.paginated_invoices = self.invoices.paginate(page: params[:page], per_page: (params[:per_page] || 30))
    end

    def po_invoice_status_count    
      get_count(InwardInvoiceType.id_for(:tax_invoice))
    end

    def non_po_invoice_status_count
      get_count(InwardInvoiceType.id_for(:non_po_invoice))
    end

    def get_count(id)
      raw_count = self.invoices.where(invoice_type_id: id).group( :invoice_status_id).count
      h = {}
      InwardInvoiceStatus.all.each {|ps| if raw_count.keys.include? ps.id then h[ps.name] = sprintf '%02d', raw_count[ps.id] else h[ps.name] = sprintf '%02d', 0 end}
      return h
    end

  end

  attr_accessor :invoices

  def init
    if user.vendor_payments_admin?
      self.invoices = user.company.inward_invoices.non_beneficiary.created_at_desc
      return
    end
    unless user.policy_user_roles.pluck(:user_role_id).uniq.blank?
      self.invoices  = ::Invoice.associated_items(user, ::Invoice.roles)
    end
  end

  def success
    params[:invoices] = self.invoices
    BankTransfer::InwardInvoices::Index::InwardInvoicesPresenter.new(user, params, messages)
  end

end