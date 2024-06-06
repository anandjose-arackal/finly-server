# == Schema Information
#
# Table name: invoices
#
#  id                                    :integer          not null, primary key
#  address_id                            :integer
#  date                                  :date
#  due_date                              :date
#  invoice_number                        :text(65535)
#  tax_type_id                           :integer
#  discount                              :decimal(64, 12)
#  discount_type_id                      :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  gross_amount_id                       :integer
#  net_amount_id                         :integer
#  inclusive_of_taxes                    :boolean
#  amount_id                             :integer
#  tds                                   :decimal(64, 12)
#  tds_type_id                           :integer
#  gst_type_id                           :integer
#  payment_id                            :integer
#  discount_amount_id                    :integer
#  tds_amount_id                         :integer
#  tax_amount_id                         :integer
#  tax                                   :decimal(64, 12)
#  category_id                           :integer
#  original_amount_id                    :integer
#  advance_amount_id                     :integer
#  advance_type_id                       :integer
#  advance                               :decimal(20, 10)
#  freight_amount_id                     :integer
#  freight_type_id                       :integer
#  freight                               :decimal(20, 10)
#  roundoff_amount                       :decimal(20, 10)
#  balance_due_id                        :integer
#  taxable_amount_id                     :integer
#  cost_center_id                        :integer
#  tds_slab_id                           :integer
#  invoice_status_id                     :integer
#  company_id                            :integer
#  created_by_user_id                    :integer
#  paid_amount_id                        :integer
#  vendor_id                             :integer
#  receiving_account_id                  :integer
#  receiving_account_type                :string(255)
#  note                                  :text(65535)
#  procurement_id                        :integer
#  remaining_amount_id                   :integer
#  invoice_type_id                       :integer
#  location_id                           :integer
#  delivery_location_id                  :integer
#  payment_term_id                       :integer
#  department_id                         :integer
#  sub_department_id                     :integer
#  policy_id                             :integer
#  controlling_level_id                  :integer
#  controlling_user_id                   :integer
#  controlling_user_role_id              :integer
#  controlling_for_user_id               :integer
#  controlling_for_user_role_id          :integer
#  billing_address                       :text(65535)
#  shipping_address                      :text(65535)
#  is_template                           :boolean          default(FALSE)
#  template_name                         :string(255)
#  is_deleted                            :boolean          default(FALSE)
#  resource_template_id                  :integer
#  invoice_id                            :string(255)
#  deleted_at                            :datetime
#  submitted_at                          :datetime
#  approved_at                           :datetime
#  po_adjusted_advance                   :integer
#  po_advance                            :decimal(20, 2)
#  po_prev_adjusted_advance              :decimal(20, 2)
#  advance_amount_required               :boolean          default(FALSE)
#  gstin_location_id                     :bigint
#  transaction_service_period_from       :date
#  transaction_service_period_to         :date
#  proforma_invoice_id                   :integer
#  proforma_advance                      :integer
#  total_proforma_advance                :decimal(20, 2)
#  cost_allocation_items                 :boolean          default(FALSE)
#  po_number                             :string(255)
#  narration                             :text(65535)
#  bank_account_id                       :integer
#  payment_agreement_id                  :integer
#  vendor_location_id                    :integer
#  rejection_note                        :text(65535)
#  billing_type_id                       :integer
#  vendor_poc_id                         :integer
#  vlpm_id                               :integer
#  client_note                           :text(65535)
#  agreement_item_type                   :string(255)
#  agreement_item_id                     :integer
#  payable                               :boolean          default(FALSE)
#  cn_adjusted_amount_id                 :integer
#  rcm_enabled                           :boolean          default(FALSE)
#  tds_percentage                        :decimal(20, 5)
#  vendor_bank_account_number            :string(255)
#  vendor_bank_account_ifsc              :string(255)
#  invoice_gross_amount                  :decimal(20, 5)
#  invoice_discount_amount               :decimal(20, 5)
#  invoice_tax_amount                    :decimal(20, 5)
#  invoice_tds_amount                    :decimal(20, 5)
#  vendor_sequence_id                    :text(65535)
#  vendor_gstin                          :string(255)
#  invoice_freight_amount                :decimal(20, 5)
#  conversion_date                       :date
#  conversion_rate                       :decimal(10, 5)
#  retrieve_conversion_rate              :boolean          default(TRUE)
#  invoice_taxable_amount                :decimal(20, 5)
#  invoice_roundoff_amount               :decimal(20, 5)
#  invoice_balance_due                   :decimal(20, 5)
#  reporting_invoice_gross_amount        :decimal(20, 5)
#  reporting_invoice_discount_amount     :decimal(20, 5)
#  reporting_invoice_taxable_amount      :decimal(20, 5)
#  reporting_invoice_tax_amount          :decimal(20, 5)
#  reporting_invoice_tds_amount          :decimal(20, 5)
#  reporting_invoice_freight_amount      :decimal(20, 5)
#  reporting_invoice_sub_total_amount    :decimal(20, 5)
#  reporting_invoice_roundoff_amount     :decimal(20, 5)
#  invoice_advance_paid_amount           :decimal(20, 5)
#  reporting_invoice_advance_paid_amount :decimal(20, 5)
#  reporting_invoice_total_amount        :decimal(20, 5)
#  invoice_net_total_amount              :decimal(20, 5)
#  reporting_invoice_net_total_amount    :decimal(20, 5)
#  reporting_invoice_paid_outside_amount :decimal(20, 5)
#  reporting_invoice_balance_due         :decimal(20, 5)
#  erp_sync_status_id                    :integer
#  erp_sync_message                      :text(65535)
#  erp_sync_reference_id                 :text(65535)
#  erp_sync_attempts_count               :integer          default(0)
#  erp_sync_attempted_at                 :datetime
#  approval_workflow_version             :integer
#  is_workflow_v2                        :boolean          default(FALSE)
#  vendor_trade_name                     :string(255)
#  vendor_pan                            :string(255)
#  invoice_paid_outside_amount           :decimal(20, 5)
#  invoice_sub_total_amount              :decimal(20, 5)
#  invoice_total_amount                  :decimal(20, 5)
#  payment_term_days                     :integer          default(0)
#  vendor_bank_account_swift_code        :string(255)      default("")
#  discount_type                         :string(255)      default("")
#  overall_discount_amount               :decimal(10, )    default(0)
#  total_line_item_discount_amount       :decimal(10, )    default(0)
#  is_domestic                           :boolean          default(TRUE)
#  billing_address_name                  :string(255)      default("")
#  billing_address_gstin                 :string(255)      default("")
#  shipping_address_name                 :string(255)      default("")
#  shipping_address_gstin                :string(255)      default("")
#  base_currency_id                      :integer
#  reporting_currency_id                 :integer
#  vendor_country_id                     :integer
#

class Invoice < ApplicationRecord
  attr_accessor :skip_callback, :remaining_adjustable_tds, :remaining_adjustable_advance, :po_advance_tds, :net_po_advance, :prev_adjusted_advance_tds, :advance_paid, :vendor_country_id_value
  include Templatable, Transitionable, MathUtil, CustomFieldFilterSupport, ControllingUser, GetCurrency
  include LiquidDroppable
  include Exposures::Model::Exposable
  include Sequenced::ActsAsSequenced
  include FormsHelper
  include ErpSyncable
  # include SearchIndex::Concerns::Document
  include Searchkick::Api

  # Multicurrency Support
  include Monetizable
  money :invoice_gross_amount, :get_reporting_currency
  money :invoice_discount_amount, :get_reporting_currency
  money :invoice_tax_amount, :get_reporting_currency
  money :invoice_tds_amount, :get_reporting_currency
  money :invoice_paid_outside_amount, :get_reporting_currency
  money :invoice_sub_total_amount, :get_reporting_currency
  money :invoice_total_amount, :get_reporting_currency
  money :invoice_taxable_amount, :get_reporting_currency
  money :invoice_freight_amount, :get_reporting_currency
  money :invoice_roundoff_amount, :get_reporting_currency
  money :invoice_balance_due, :get_reporting_currency

  # def get_reporting_currency
  #   Currency.currency_for(self.reporting_currency ) rescue self.company.reporting_currency.country_code
  # end

  # def get_base_currency
  #   currency_code = Currency.find(self.base_currency)&.country_code rescue nil
  #   Currency.currency_for(currency_code || "INR")
  # end

  
  def vendor_country_id_value
    self.vendor_country&.name
  end


  exchange_bank :get_reporting_currency, :get_base_currency, :exchange_rate

  # exchange_rate as method
  def exchange_rate
    ExchangeRate.get_rate(
      self.conversion_date,
      self.get_reporting_currency.country_code,
      get_base_currency&.country_code || "INR"
    )
  end

  alias_attribute :created_by_id, :created_by_user_id

  # Multicurrency Attributes

  # include EventProducer

  acts_as_sequenced column: :invoice_id, purpose: :invoice, editable: false, prefix: 'INV'

  default_scope { order(created_at: :desc) }

  belongs_to :address, optional: true
  # #### Fixme: These associations are deprecated to support amount number fields with the same name.
  # #### Fixme: This can be cleared once this has been deployed to production
  belongs_to :amount, optional: true
  belongs_to :gross_amount, optional: true, class_name: "Amount"
  belongs_to :net_amount, optional: true, class_name: "Amount"
  belongs_to :tds_amount, optional: true, class_name: "Amount"
  belongs_to :tax_amount, optional: true, class_name: "Amount"
  belongs_to :discount_amount, optional: true, class_name: "Amount"
  belongs_to :original_amount, optional: true, class_name: "Amount"
  belongs_to :advance_amount, optional: true, class_name: "Amount"
  belongs_to :freight_amount, optional: true, class_name: "Amount"
  belongs_to :balance_due, optional: true, class_name: "Amount"
  belongs_to :taxable_amount, optional: true, class_name: "Amount"
  belongs_to :paid_amount, optional: true, class_name: "Amount"

  #
  # Captures PO advance if any and how much is adjusted in the tax invoice
  # belongs_to :po_prev_adjusted_advance, optional: true, class_name: "Amount", foreign_key: :po_prev_adjusted_advance
  belongs_to :po_adjusted_advance, optional: true, class_name: "Amount", foreign_key: :po_adjusted_advance
  belongs_to :proforma_advance, optional: true, class_name: "Amount", foreign_key: :proforma_advance
  # #### Fixme: END

  belongs_to :category, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :created_by, optional: true, class_name: "User", foreign_key: :created_by_user_id
  belongs_to :company, optional: true
  belongs_to :invoice_status, optional: true, class_name: "InwardInvoiceStatus"
  belongs_to :status, optional: true, class_name: "InwardInvoiceStatus", foreign_key: :invoice_status_id
  belongs_to :receiving_account, optional: true, polymorphic: true
  belongs_to :vendor, optional: true, class_name: "YesBankVendor"
  belongs_to :location, optional: true, class_name: 'BranchLocation'
  belongs_to :delivery_location, optional: true, class_name: 'BranchLocation'

  belongs_to :procurement, optional: true, class_name: "Procurement"
  belongs_to :remaining_amount, optional: true, class_name: "Amount"
  belongs_to :invoice_type, optional: true, class_name: "InwardInvoiceType"
  belongs_to :gst_type, optional: true
  belongs_to :tax_type, optional: true
  belongs_to :tds_slab, optional: true, class_name: 'TdsRatesList'
  belongs_to :payment_term, optional: true

  belongs_to :controlling_user, optional: true, class_name: 'User'
  belongs_to :controlling_for_user, optional: true, class_name: 'User'
  belongs_to :controlling_user_role, optional: true, class_name: 'UserRole'
  belongs_to :controlling_for_user_role, optional: true, class_name: 'UserRole'

  belongs_to :department, optional: true
  belongs_to :sub_department, optional: true, class_name: 'Department', foreign_key: :sub_department_id

  belongs_to :policy, optional: true
  belongs_to :level, optional: true, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id
  belongs_to :gstin_location, class_name: "GstinLocation", optional: true
  belongs_to :billing_type, optional: true
  belongs_to :vendor_location, class_name: "GstinLocation", optional: true
  belongs_to :payment_agreement, optional: true
  belongs_to :agreement_item, optional: true, polymorphic: true
  belongs_to :base_currency, optional: true, class_name: 'Currency'
  belongs_to :reporting_currency, optional: true, class_name: 'Currency'
  belongs_to :vendor_country, optional: true, class_name: 'Country'

  has_one :credit_note
  has_many :document_level_reviewer_mappings, as: :document_reviewer_mappable

  # because multiple payments can be made against one invoice
  has_many :payments
  has_many :successful_payments, -> { successful }, class_name: 'Payment'

  has_many :email_approvals, as: :documentable

  has_many :invoice_items, class_name: "InvoiceLineItem", as: :parent
  has_many :items, class_name: "InvoiceLineItem", as: :parent
  has_many :line_items, class_name: "InvoiceLineItem", as: :parent
  # Standardizing where all attachments are stored
  has_many :invoice_attachments

  # Attachments created for procurement
  has_many :attachments, class_name: 'ProcurementAttachment', as: :procurement_document
  # Fixme: Migration of all invoice_attachment to attachments is still pending
  # Fixme: Need to check where the previous attachments was being used as this is overriding it
  # has_many :attachments, as: :resource # todo - I2P
  has_many :custom_fields, as: :parent, dependent: :destroy
  has_many :form_custom_fields, class_name: 'FormCustomField', as: :document, dependent: :destroy

  # From Procurement workflow
  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable

  has_many :trails, as: :parent
  has_many :notify_users, as: :document
  has_many :credit_note_adjustments, dependent: :destroy
  has_many :credit_notes, through: :credit_note_adjustments

  has_paper_trail(
    meta: {
      parent_document_type: "Invoice",
      document_number: Proc.new { |document| document.invoice_id }
    }
  ) if Proc.new { |inv| inv.invoice_type_id == InwardInvoiceType.id_for(:tax_invoice) || inv.invoice_type_id == InwardInvoiceType.id_for(:non_po_invoice) }

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :invoice_attachments, allow_destroy: true
  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :gross_amount
  accepts_nested_attributes_for :net_amount
  accepts_nested_attributes_for :discount_amount
  accepts_nested_attributes_for :tds_amount
  accepts_nested_attributes_for :tax_amount
  accepts_nested_attributes_for :original_amount
  accepts_nested_attributes_for :freight_amount
  accepts_nested_attributes_for :custom_fields
  accepts_nested_attributes_for :advance_amount
  accepts_nested_attributes_for :balance_due
  accepts_nested_attributes_for :invoice_items, allow_destroy: true
  # accepts_nested_attributes_for :po_prev_adjusted_advance
  accepts_nested_attributes_for :po_adjusted_advance
  accepts_nested_attributes_for :proforma_advance
  accepts_nested_attributes_for :notify_users, allow_destroy: true
  accepts_nested_attributes_for :credit_note_adjustments, allow_destroy: true

  delegate :tax_amount_value, to: :tax_amount
  delegate :tds_amount_value, to: :tds_amount
  delegate :discount_amount_value, to: :discount_amount
  delegate :net_amount_value, to: :net_amount
  delegate :gross_amount_value, to: :gross_amount
  delegate :paid_amount_value, to: :paid_amount

  delegate :unpaid?, :partially_paid?, :paid?, :open?, :processing?, :rejected?,
           :approved?, :retracted?, :auto_approved?, :initiated?, :closed?, :voided?, to: :invoice_status, allow_nil: true
  delegate :payment?, :advance?, :tax_invoice?, to: :invoice_type

  attr_accessor :invoice_custom_fields, :display_tds_amount

  # validates :gross_amount, presence: true
  # validates :net_amount, presence: true
  # validates :amount, presence: true

  validates :invoice_number, :format => {with: /\A[a-zA-Z0-9 \\\/\-\#\&\_]*\Z/, :message => ' can only have letters, numbers, spaces, -,#,&,/ and underscore. No other special characters'}, :length => {minimum: 0, maximum: 30}, :allow_blank => true
  # validate :item_quantity_validation
  # validate :item_rate_validation
  validate :multiple_invoice_validation

  before_destroy :rollback_agreement_invoice
  before_create :set_currency

  def set_currency
    self.reporting_currency_id = self.company.reporting_currency.id if self.reporting_currency.blank?
    self.base_currency_id = self.company.reporting_currency.id if self.base_currency.blank?
    self.conversion_rate = 1
  end

  scope :with_company_id, -> (company_id) { where company_id: company_id }
  scope :with_id, -> (id) { where id: id }
  scope :without_id, -> (id) { where.not(id: id) }
  scope :with_cost_center_id, -> (id) { where cost_center_id: id }
  scope :not_open, -> { where.not invoice_status_id: InwardInvoiceStatus.id_for(:open) }
  scope :with_controlling_level_ids, -> (level_ids) { where controlling_level_id: level_ids }
  scope :with_controlling_user_id, -> (id) { where controlling_user_id: id }
  scope :with_procurement_id, ->(procurement_id) { where procurement_id: procurement_id }
  scope :with_procurement, -> { where("invoices.procurement_id IS NOT NULL") }
  scope :with_vendor_ids, -> (ids) { where vendor_id: ids }
  scope :with_created_by_user_id, -> (user_ids) { where created_by_user_id: user_ids }
  scope :with_budgetable_department_ids, -> (department_ids) {
    if department_ids.present?
      ids = where(department_id: department_ids).pluck(:id)
      ids += where(sub_department_id: department_ids).pluck(:id)
      where(id: ids)
    end
  }
  scope :with_budgetable_location_ids, -> (location_ids) {
    if location_ids.present?
      where location_id: location_ids
    end
  }
  scope :with_budgetable_user_ids, -> (user_ids) {
    if user_ids.present?
      where created_by_user_id: user_ids
    end
  }

  scope :with_budgetable_vendor_ids, -> (vendor_ids) {
    if vendor_ids.present?
      where vendor_id: vendor_ids
    end
  }

  scope :with_type_non_po_invoice, -> {
    where invoice_type_id: InwardInvoiceType.id_for(:non_po_invoice)
  }

  scope :with_type_po_invoice, -> {
    where invoice_type_id: InwardInvoiceType.id_for(:tax_invoice)
  }

  scope :with_status_id, -> (status_id) {
    case status_id
    when InwardInvoiceStatus::GROUP_OPEN
      # open / retracted
      where invoice_status_id: InwardInvoiceStatus.ids_for(:open, :retracted)
    when InwardInvoiceStatus::GROUP_AWAITING_APPROVAL
      # awaiting approval
      user_id = RequestStore.store[:current_user]&.id
      if user_id.present?
        where("#{table_name}.invoice_status_id": InwardInvoiceStatus.id_for(:processing)).awaiting_action_items(user_id)
      else
        self.none
      end
    when InwardInvoiceStatus::GROUP_PENDING_PAYMENT
      # approved/auto_approved/partially_paid/unpaid/initiated
      where invoice_status_id: InwardInvoiceStatus.ids_for(:approved, :auto_approved, :partially_paid, :unpaid, :initiated)
    else
      where(invoice_status_id: status_id)
    end
  }

  scope :with_status_ids, -> (status_id) {
    with_status_id(status_id)
  }

  scope :filter_payable_invoices, -> (enabled) {
    if StringUtils.to_bool(enabled)
      ids = self.joins(:balance_due).non_beneficiary.where(invoice_status_id: InwardInvoiceStatus.ids_for([:unpaid, :partially_paid, :approved, :auto_approved, :initiated]), payable: true).where.not(amounts: { value: 0 }).pluck(:id)
      where id: ids
    end
  }


  scope :filter_base_currency, -> (base_currency_id) { where base_currency_id: base_currency_id }

  # scope :filter_awaiting_approval, -> (enabled) {
  #   if StringUtils.to_bool(enabled)
  #     where(invoice_status_id: InwardInvoiceStatus.id_for(:processing))
  #   end
  # }

  # scope :filter_awaiting_approval, -> (user) {
  #   if user.vendor_payments_reviewer?
  #     # invoice_ids = Invoice.awaiting_action_items(user).pluck(:id).compact
  #     # where(id: invoice_ids.uniq)
  #     self.awaiting_action_items(user)
  #   end
  # }

  scope :filter_awaiting_approval, -> (user) {
    if user.present? && user.instance_of?(User)
      user_id = user.id
    else
      user_id = RequestStore.store[:current_user]&.id
    end

    if user_id.present?
      ids = self.select(:id).awaiting_action_items(user_id)
      where(id: ids)
    end
  }

  scope :filter_reviewer_awaiting_approval, -> (user_id = nil) {
    if user_id.present?
      self.awaiting_action_items(user_id)
    end
  }

  scope :filter_ids, ->(ids) {
    where id: ids
  }

  scope :filter_department_id, -> (ids) {
    where department_id: ids
  }

  scope :filter_sub_department_id, -> (ids) {
    where sub_department_id: ids
  }

  scope :invoice_date, -> (from, to) {
    from = Date.parse(from) rescue Date.parse('01-01-1990') unless from.is_a?(Date)
    to = Date.parse(to) rescue Date.today unless to.is_a?(Date)
    where('date >= ? && date <= ?', from, to)
  }

  scope :filter_creation_date, -> (from, to) {
    from = Date.parse(from) rescue Date.parse('01-01-1990') unless from.is_a?(Date)
    to = Date.parse(to) rescue Date.today unless to.is_a?(Date)
    where('invoices.created_at >= ? && invoices.created_at <= ?', from.beginning_of_day, to.end_of_day)
  }

  scope :filter_approved_date, -> (from, to) {
    from = Date.parse(from) rescue Date.parse('01-01-1990') unless from.is_a?(Date)
    to = Date.parse(to) rescue Date.today unless to.is_a?(Date)
    where('invoices.approved_at >= ? && invoices.approved_at <= ?', from.beginning_of_day, to.end_of_day)
  }

  scope :filter_invoice_date, -> (from) {
    from = Date.parse(from) rescue Date.today
    where('date = ?', from)
  }

  #scope for exportar screen
  scope :filter_date, -> (from, to) {
    from = Date.parse(from) rescue Date.parse('01-01-1990') unless from.is_a?(Date)
    to = Date.parse(to) rescue Date.today unless to.is_a?(Date)
    where('invoices.created_at >= ? && invoices.created_at <= ?', from.beginning_of_day, to.end_of_day)
  }

  scope :due_date, -> (from, to) {
    from = Date.parse('01-01-1990') if from.blank?
    to = Date.today if to.blank?
    from = Date.parse(from) rescue Date.parse('01-01-1990') unless from.is_a?(Date)
    to = Date.parse(to) rescue Date.today unless to.is_a?(Date)
    where('due_date >= ? && due_date <= ?', from, to)
  }

  scope :filter_due_date, -> (from) {
    from = Date.parse(from) rescue Date.today
    where('due_date = ?', from)
  }

  scope :created_at_desc, -> { order(created_at: :desc) }
  scope :created_at_asc, -> { order(created_at: :asc) }

  scope :with_cost_center_id, -> (id) { where cost_center_id: id }
  scope :filter_cost_center_id, -> (id) { where cost_center_id: id } #somewhere FE is using this

  # this scope checks for an exact match of invoice number
  scope :with_invoice_number, -> (invoice_number) { where invoice_number: invoice_number }

  # this scope checks for an approximate match - used in searches etc.
  scope :filter_invoice_number, -> (invoice_number) { where 'invoices.invoice_number LIKE ?', "%#{invoice_number}%" }
  scope :filter_invoice_id, -> (invoice_id) { where 'invoices.invoice_id like ?', "%#{invoice_id}%" }
  scope :filter_inward_invoice_type, -> (invoice_type) {
    where invoice_type_id: InwardInvoiceType.id_for(invoice_type)
  }

  scope :filter_po_invoice, -> {
    where invoice_type_id: InwardInvoiceType.id_for(:tax_invoice)
  }

  scope :filter_policy_id, -> (policy_id) { where policy_id: policy_id }
  scope :filter_location_id, -> (location_id) { where("location_id = ? OR delivery_location_id = ?", location_id, location_id) }

  scope :filter_non_po_invoice, -> {
    where invoice_type_id: InwardInvoiceType.id_for(:non_po_invoice)
  }

  scope :filter_invoice_type, -> (type) {
    case type
    when 'po_invoice'
      where invoice_type_id: InwardInvoiceType.id_for(:tax_invoice)
    when 'non_po_invoice'
      where invoice_type_id: InwardInvoiceType.id_for(:non_po_invoice)
    when 'agreement_invoice', 'recurring_invoice'
      where invoice_type_id: [InwardInvoiceType.id_for(:recurring_invoice), InwardInvoiceType.id_for(:agreement_invoice)]

    else
      return nil
    end
  }

  scope :filter_status, -> (status_name) {
    all_statuses = InwardInvoiceStatus.all.pluck(:name)
    if status_name.present? && all_statuses.include?(status_name)
      where invoice_status_id: InwardInvoiceStatus.id_for(status_name)
    end
  }

  scope :filter_status_id, -> (ids) {
    with_status_id(ids)
  }

  scope :non_beneficiary, -> {
    where(invoice_type_id: [InwardInvoiceType.id_for(:tax_invoice),
                            InwardInvoiceType.id_for(:advance),
                            InwardInvoiceType.id_for(:non_po_invoice),
                            InwardInvoiceType.id_for(:recurring_invoice),
                            InwardInvoiceType.id_for(:agreement_invoice),
                            nil])
  }

  scope :filter_by_created_at, -> (created_at) {
    created_at = Date.parse(created_at).strftime('%Y-%m-%d')
    # where created_at: created_at
    where("DATE(created_at) >= ?", created_at)
  }

  scope :filter_vendor_id, -> (ids) {
    where vendor_id: ids
  }

  scope :filter_po_number, -> (po_number) {
    # ipid = where(invoice_type_id: InwardInvoiceType.id_for(:tax_invoice)).pluck(:procurement_id)
    # poid = PurchaseOrder.filter_po_number(po_number).pluck(:procurement_id)

    # procs = ipid & poid
    poid = PurchaseOrder.filter_po_number(po_number).pluck(:procurement_id)

    where(procurement_id: poid)

  }

  scope :include_for_index, -> {
    includes(:amount, :gross_amount, :net_amount, :tds_amount, :tax_amount, :discount_amount, :invoice_status, :tds_slab, :category, :invoice_type, :level, :controlling_level,
             :original_amount, :freight_amount, :taxable_amount, :advance_amount, :balance_due, :cost_center, :gst_type,
             :invoice_items, :invoice_attachments, :attachments, :custom_fields, invoice_items: [:amount, :discount_amount, :tax_amount, :net_amount, :taxable_amount, :tax_rate], vendor: [:bank_accounts], procurement: [:purchase_order], payments: [:amount]) #.where(payments: {payment_status_id: PaymentStatus.id_for(:completed)})
  }

  scope :filter_user, -> (user = nil) {
    if user.present? && user.instance_of?(User)
      user_id = user.id
    elsif user.instance_of?(TrueClass)
      user_id = RequestStore.store[:current_user]&.id
    else
      user_id = RequestStore.store[:current_user]&.id
    end

    if user_id.present?
      with_created_by_user_id(user_id)
    end
  }

  scope :filter_with_credit_note, -> (enabled) {
    if enabled
      joins(:credit_note_adjustments).where("credit_note_adjustments.id IS NOT NULL")
    end
  }

  scope :filter_year, -> (year) {
    if year.blank?
      year = Date.today.year
    end
    where('extract(year from created_at) = ?', year)
  }

  scope :filter_month, -> (month) {
    if month.blank?
      month = Date.today.month
    end
    where('extract(month from created_at) = ?', month)
  }

  scope :filter_cost_center_id, -> (cost_center_id) { where(cost_center_id: cost_center_id) }

  scope :show_only_invoices_which_are_forwarded, -> (show_it = false) {
    if StringUtils.to_bool(show_it)
      self.joins(:document_level_reviewer_mappings).where('document_level_reviewer_mappings.forwarded is true')
    end
  }

  scope :filter_rcm_enabled, -> (enabled) {
    where(rcm_enabled: true) if StringUtils.to_bool(enabled)
  }

  scope :rcm_enabled, -> (enabled) {
    where(rcm_enabled: true) if StringUtils.to_bool(enabled)
  }

  scope :includes_for_contract, -> {
    includes(:created_by, :invoice_type, :form_custom_fields, :items, :credit_note_adjustments)
  }

  # Sorting
  scope :sort_invoice_id, -> (type) {
    type = type&.strip&.upcase
    if type && ['ASC', 'DESC'].include?(type)
      # nosqli - The incoming var is checked to be ASC or DESC and then only substituted, not other value other than "ASC" or "DESC" possible
      reorder("invoices.invoice_id #{type}")
    end
  }

  scope :sort_date, -> (type) {
    type = type&.strip&.upcase
    if type && ['ASC', 'DESC'].include?(type)
      # nosqli - The incoming var is checked to be ASC or DESC and then only substituted, not other value other than "ASC" or "DESC" possible
      reorder("invoices.date #{type}")
    end
  }

  scope :sort_due_date, -> (type) {
    type = type&.strip&.upcase
    if type && ['ASC', 'DESC'].include?(type)
      # nosqli - The incoming var is checked to be ASC or DESC and then only substituted, not other value other than "ASC" or "DESC" possible
      reorder("invoices.due_date #{type}")
    end
  }

  # used for streamsets
  scope :filter_invoice_status, -> (status) {
    status = [status] unless status.is_a? Array
    permitted_status = ['partially_paid', 'approved', 'auto_approved', 'initiated', 'unpaid']
    status = permitted_status & status
    status = permitted_status if status.blank?
    where invoice_status_id: InwardInvoiceStatus.ids_for(status)
  }

  scope :scope_all_except_voided, -> {
    where.not invoice_status_id: InwardInvoiceStatus.id_for(:voided)
  }

  scope :scope_all_except_voided_rejected_retracted, -> {
    where.not invoice_status_id: [InwardInvoiceStatus.id_for(:voided),
                                  InwardInvoiceStatus.id_for(:rejected),
                                  InwardInvoiceStatus.id_for(:retracted)]
  }
  scope :scope_all_except_voided_rejected_open, -> {
    where.not invoice_status_id: [InwardInvoiceStatus.id_for(:voided),
                                  InwardInvoiceStatus.id_for(:rejected),
                                  InwardInvoiceStatus.id_for(:open),
                                  InwardInvoiceStatus.id_for(:retracted)]
  }

  scope :scope_all_except_voided_rejected, -> {
    where.not invoice_status_id: [InwardInvoiceStatus.id_for(:voided),
                                  InwardInvoiceStatus.id_for(:rejected)]
  }

  scope :pending_erp_sync, -> (*args) {
    with_erp_sync_status_pending.
      where(invoice_status_id: InwardInvoiceStatus.ids_for(:unpaid, :partially_paid, :paid, :approved, :auto_approved, :closed, :initiated))
  }

  after_create :set_defaults
  after_save :sync_amounts, unless: :skip_callback
  after_save :set_currency_for_amount, unless: :skip_callback
  after_save :budget_trail_entry, if: :budget_enabled?
  # the below callback deals with cases where the PO advance has been paid, and then an invoice is being raised
  # after_save :handle_po_advance_budget_trails
  after_destroy :budget_trail_destroy

  template_merge :procurement_id
  template_config do
    include_association [:address, :category, :cost_center, :company, :receiving_account, :vendor, :location,
                         :delivery_location, :remaining_amount, :invoice_type, :gst_type,
                         :tds_slab, :payment_term, :department, :sub_department, :policy]

    clone [:amount, :gross_amount, :net_amount, :tds_amount, :tax_amount, :discount_amount,
           :original_amount, :freight_amount, :taxable_amount,
           :invoice_items, :invoice_attachments, :attachments, :custom_fields,
           :document_level_reviewer_mappings]

    customize(lambda { |invoice, new_invoice|
      new_invoice.trails.destroy_all
      new_invoice.comments.destroy_all
      new_invoice.attachments.destroy_all
      new_invoice.payments.destroy_all
    })

    nullify :procurement_id
    nullify :created_by_user_id
    nullify :invoice_status_id
    nullify :remaining_amount_id
    nullify :advance_amount_id
    nullify :balance_due_id
    nullify :controlling_level_id
    nullify :controlling_user_id
    nullify :controlling_for_user_id
    nullify :controlling_user_role_id
    nullify :controlling_for_user_role_id
    nullify :template_name
    nullify :is_template
    nullify :invoice_number
    nullify :date
    nullify :due_date
    set :invoice_status_id => InwardInvoiceStatus.id_for(:open)
  end

  ransack_scopes :with_status_id
  ransack_scopes :with_status_ids

  def form_klass
    invoice_type = self.invoice_type&.name&.to_sym || :non_po_invoice
    Forms::Router.klass(invoice_type)&.name
  end

  # This method is to get Invoice ID from Form Autonumber Entity
  def get_form_based_next_sequence(seq_prefix)
    forms_enabled = NonPoInvoiceToggle.new(RequestStoreUtil.current_user).enabled?
    return nil unless forms_enabled

    invoice_form_class_name = Forms::Router.klass(:invoices)&.name

    invoice_form = Form.find_by(klass_name: invoice_form_class_name, company_id: self.company_id)
    return nil unless invoice_form.present?

    sequence_entity = (invoice_form.entities.where(type: 'FormEntity::AutoNumber').filter do |e|
      e.config.dig("sequence", "prefix") == seq_prefix
    end).first

    return nil unless sequence_entity.present?

    prefix, sequence = FormEntity::AutoNumber.fetch_autonumber(sequence_entity, self)
    prefix + sequence
  end

  def policy
    return super if self.policy_id.present?
    # self.payments&.first&.payment_order&.bank_payment_request&.policy
  end

  # the 'user' will default to the initiating user of the payment
  def user
    self.payment.initiating_user
  end

  def tax_rate
    self.tax
  end

  def advance_rate
    self.advance
  end

  def tds_rate
    if forms_enabled
      self.tds_percentage
    else
      self.tds
    end
  end

  def discount_rate
    self.discount
  end

  def po_advance_tds
    self.forms_enabled ? self.procurement.purchase_order.po_advance_tds_amount.to_f : 0
  end

  def item_amounts_total
    if self.invoice_items.present?
      # user = RequestStore.store[:current_user]
      # configuration = user.company.feature_subscription.srn_enabled rescue false
      configuration = self.company.feature_subscription.srn_enabled rescue false
      if self.invoice_type_id == InwardInvoiceType.id_for(:tax_invoice) && configuration # if srn feature enabled for company, return sum of billable amount for services, amount for goods
        return self.invoice_items.includes(:inventory_line_item, :amount).map { |p|
          if p.inventory_line_item&.product_type_id == ProductType.id_for(:service) then
            p.billable_amount&.value
          else
            p.amount&.value
          end }.compact.sum
      end

      # return self.invoice_items.joins(:amount).sum(:value)
      return self.invoice_items.includes(:amount).map { |p| p.amount&.value }.compact.sum
    else
      return 0
    end
  end

  def payment_amounts_total(completed_only = true)
    if self.payments.present?
      # return self.payments.successful.joins(:amount).sum(:value)
      if completed_only
        return self.payments.map { |p| p.amount.value if (p.payment_status_id == PaymentStatus.id_for(:completed)) }.compact.sum
      else
        return self.payments.map { |p| p.amount.value if (PaymentStatus.all_except_failed.include? p.payment_status_id) }.compact.sum
      end
    else
      return 0
    end
  end

  def item_quantity_total
    if self.invoice_items.present?
      # return self.invoice_items.sum(:quantity)
      return self.invoice_items.map { |p| p.quantity }.sum
    else
      return 0
    end
  end

  def bank_account
    if self.receiving_account_type == "BankAccount"
      return self.receiving_account
    end
    nil
  end

  def available_credits
    available_credit_data = self.vendor.credit_notes.filter_adjustables.group(:currency_id).sum(:value)
    result = []
    available_credit_data.keys.each do |currency_id|
      data = {
        currency: Currency.find(currency_id).as_json,
        amount: available_credit_data[currency_id]
      }

      result.push(data)
    end
    result
  end

  def awaiting_action(user)
    # awaiting_action = false
    # if self.level&.reviewers&.include? user
    #   awaiting_action = true
    #   return awaiting_action
    # end
    # awaiting_action
    return false if user.blank?
    self.get_reviewers.include? user
  end

  def balance_payable
    if self.forms_enabled
      self.invoice_balance_due
    else
      balance_due&.value.to_f - paid_amount_value
    end
  end

  def paid_amount_value
    successful_payments.map { |i| (i&.amount&.value || 0) }.inject(0, :+) || 0
  end

  # this method updates the invoice status based on the associated
  # payments made against this particular invoice
  def update_invoice_status
    balance_due = self.forms_enabled ? self.invoice_balance_due.to_f : self.balance_due&.value.to_f
    # if forms is enabled, invoice_balance_due should be populated but in some cases it's not so balance due becomes 0
    if balance_due == 0 && self.balance_due&.value.to_f > 0
      balance_due = self.balance_due&.value.to_f
    end
    paid_amount = self.payments.successful.joins(:amount).sum(:value)

    if paid_amount == 0
      self.update(invoice_status_id: InwardInvoiceStatus.id_for(:unpaid))
    elsif ((!self.forms_enabled || self.invoice_type_id == InwardInvoiceType.id_for(:non_po_invoice)) && paid_amount >= balance_due - 0.99) || ((balance_due == 0 || paid_amount >= balance_due - 0.99) && self.forms_enabled)
      self.update(invoice_status_id: InwardInvoiceStatus.id_for(:paid), payable: false)
    elsif (!self.forms_enabled && paid_amount <= balance_due) || (self.forms_enabled && self.invoice_paid_outside_amount.to_f > 0)
      self.update(invoice_status_id: InwardInvoiceStatus.id_for(:partially_paid))
    end

    update_paid_and_balance_payable paid_amount
  end

  def update_paid_and_balance_payable paid_amount
    conversion_rate = self.conversion_rate.to_f

    invoice_paid_outside_amount = paid_amount.to_f
    reporting_invoice_paid_outside_amount = invoice_paid_outside_amount * conversion_rate.to_f

    self.update({
      invoice_paid_outside_amount: invoice_paid_outside_amount,
      reporting_invoice_paid_outside_amount: reporting_invoice_paid_outside_amount
    })
  end

  def invoice_balance_due
    if self.forms_enabled
      # self.invoice_type.tax_invoice? ? self[:invoice_balance_due].to_f - self[:invoice_paid_outside_amount].to_f : self[:invoice_balance_due].to_f
      self[:invoice_balance_due].to_f
    else
      balance_due&.value.to_f - paid_amount_value
    end
  end

  def reporting_invoice_balance_due
    if self.forms_enabled
      invoice_balance_due.to_f * self.conversion_rate.to_f
    else
      balance_due&.value.to_f - paid_amount_value
    end
  end

  def invoice_sub_total_amount
    if self.forms_enabled
      self[:invoice_sub_total_amount]
    else
      self.net_amount&.value.to_f
    end
  end

  def reporting_invoice_sub_total_amount
    if self.forms_enabled
      self[:reporting_invoice_sub_total_amount]
    else
      self.net_amount&.value.to_f
    end
  end

  def invoice_net_total_amount
    if self.forms_enabled
      self[:invoice_net_total_amount]
    else
      # self.net_amount - tds - paid_outside_amount + round
      self.net_amount&.value.to_f - self.tds_amount&.value.to_f - self.advance.to_f + self.roundoff_amount.to_f
    end
  end

  def reporting_invoice_net_total_amount
    if self.forms_enabled
      self[:reporting_invoice_net_total_amount]
    else
      self.invoice_net_total_amount.to_f
    end
  end

  def credit_note_adjustments_meta
    details = []
    self.credit_note_adjustments.each do |cna|
      details << {
        id: cna.id,
        cn_adjustment_amount: cna.cn_adjustment_amount,
        cn_net_adjustable_amount: cna.cn_net_adjustable_amount,
        credit_note_id: cna.credit_note_id,
      }
    end
    details
  end


  def unpaid?
    return nil if self.invoice_status.blank?
    return (self.invoice_status_id == InwardInvoiceStatus.id_for(:unpaid))
  end

  def paid?
    return nil if self.invoice_status.blank?
    return (self.invoice_status_id == InwardInvoiceStatus.id_for(:paid))
  end

  def partially_paid?
    return nil if self.invoice_status.blank?
    return (self.invoice_status_id == InwardInvoiceStatus.id_for(:partially_paid))
  end

  def initiated?
    return nil if self.invoice_status.blank?
    return (self.invoice_status_id == InwardInvoiceStatus.id_for(:initiated))
  end

  def procurement_index_details
    {
      id: id,
      document_number: self.invoice_number,
      amount: self.net_amount&.value,
      document_status: self.invoice_status&.name,
      document_owner: self.created_by&.name,
      document_type: self.class.name
    }
  end

  # def generate_sequential_id?
  #   self.invoice_type_id == InwardInvoiceType.id_for(:non_po_invoice)
  # end

  def as_json(options = {})
    if options[:payment_history]
      return payment_history_json
    else
      data = {
        id: self.id,
        invoice_type: self.invoice_type&.name,
        procurement_id: self.procurement_id,
        advance: self.advance,
        advance_amount: self.advance_amount&.value.to_f ,
        # + self&.reporting_invoice_paid_outside_amount.to_f,
        tax_amount: precision_value(self.tax_amount&.value.to_f),
        tds_amount: self.forms_enabled ? precision_value(self.display_tds_amount.to_f) : precision_value(self.tds_amount&.value.to_f),
        tax: precision_value(self.tax.to_f),
        tds: precision_value(self.tds.to_f),
        gst_type_id: self.gst_type_id.to_i,
        tax_type_id: self.tax_type_id.to_i,
        tds_type_id: self.tds_type_id.to_i,
        discount_amount: precision_value(self.discount_amount&.value.to_f),
        discount: invoice_discount_rate,
        date: self.date,
        discount_type_id: self.discount_type_id.to_i,
        due_date: self.due_date,
        invoice_number: self.invoice_number,
        invoice_id: self.invoice_id,
        inclusive_of_taxes: self.inclusive_of_taxes,
        freight_amount: self.freight_amount&.value.to_f,
        roundoff_amount: self.roundoff_amount.to_f,
        net_payable_amount: self.balance_due&.value.to_f,
        balance_due: self.balance_due&.value.to_f,
        taxable_amount: precision_value(self.gross_amount&.value.to_f),
        editable: self.unpaid? || self.initiated? || self.partially_paid?,
        tax_rate: return_tax_rate,
        tds_rate: precision_value(self.tds_rate.to_i),
        discount_rate: invoice_discount_rate,
        advance_rate: precision_value(self.advance_rate),
        net_amount: precision_value(self.net_amount&.value.to_f),
        original_amount: self.include_original_amount,
        gross_amount: precision_value(self.gross_amount&.value.to_f),
        custom_fields: self.custom_fields,
        category_id: self.category_id,
        category_name: self.category&.name,
        rcm_enabled: self.rcm_enabled,
        available_credits: self.vendor.credit_notes.filter_adjustables.joins(:net_adjustable_amount).sum(:value),
        credit_note_adjustments: self.credit_note_adjustments.as_json,
        cost_center_id: self.cost_center_id,
        cost_center_name: self.cost_center&.name,
        cost_center_id: self.cost_center_id,
        cost_center_name: self.cost_center&.name,

        tds_slab_id: self.tds_slab_id.to_i,
        tds_slab_name: self.tds_slab&.name,
        tds_rate: self.tds,

        # invoice amounts total
        item_amounts_total: self.item_amounts_total,

        # paid amount for this invoice
        # paid_amount: self.payments.successful.joins(:amount).sum(:value),
        # remaining_amount: (self.balance_due&.value.to_f - self.payments.successful.joins(:amount).sum(:value))
        paid_amount: payment_amounts_total,
        remaining_amount: (self.balance_due&.value.to_f - payment_amounts_total(false)),
        po_adjusted_advance: self.forms_enabled ? precision_value(self.adjusted_po_advance_payable_amount.to_f) : precision_value(self.po_adjusted_advance&.value),
        invoice_items: invoice_items.as_json,
        note: self.note,
        discount_amount_attributes: { id: self.discount_amount_id, value: precision_value(self.discount_amount&.value), currency_id: self.discount_amount&.currency_id },
        payment_agreement_id: self.payment_agreement_id,
        created_from_payment_agreement: self.payment_agreement_id.present?,
        agreement_number: self&.payment_agreement&.get_agreement_number,
        payable: self.payable,

        invoice_gross_amount: self.invoice_gross_amount,
        reporting_invoice_gross_amount: self.reporting_invoice_gross_amount,
        invoice_discount_amount: self.invoice_discount_amount,
        reporting_invoice_discount_amount: self.reporting_invoice_discount_amount,
        invoice_tax_amount: self.invoice_tax_amount,
        reporting_invoice_tax_amount: self.reporting_invoice_tax_amount,
        invoice_tds_amount: self.display_tds_amount,
        reporting_invoice_tds_amount: self.reporting_invoice_tds_amount,
        invoice_freight_amount: self.invoice_freight_amount,
        reporting_invoice_freight_amount: self.reporting_invoice_freight_amount,
        invoice_taxable_amount: self.invoice_taxable_amount,
        reporting_invoice_taxable_amount: self.reporting_invoice_taxable_amount,
        invoice_roundoff_amount: self.invoice_roundoff_amount,
        reporting_invoice_roundoff_amount: self.reporting_invoice_roundoff_amount,
        invoice_balance_due: self.invoice_balance_due,
        reporting_invoice_balance_due: ((self.invoice_balance_due.to_f * self.conversion_rate.to_f)/100).round(2),
        invoice_sub_total_amount: self.invoice_sub_total_amount,
        reporting_invoice_sub_total_amount: self.reporting_invoice_sub_total_amount,
        invoice_advance_paid_amount: self.invoice_advance_paid_amount,
        reporting_invoice_advance_paid_amount: self.reporting_invoice_advance_paid_amount,
        invoice_total_amount: self.invoice_total_amount,
        reporting_invoice_total_amount: self.reporting_invoice_total_amount,
        invoice_net_total_amount: self.invoice_net_total_amount,
        reporting_invoice_net_total_amount: self.reporting_invoice_net_total_amount,
        invoice_paid_outside_amount: self.invoice_paid_outside_amount,
        reporting_invoice_paid_outside_amount: self.reporting_invoice_paid_outside_amount,
        base_currency_id: self.get_base_currency.id,
        base_currency_code: self.get_base_currency.country_code,
        conversion_rate: self.conversion_rate.to_f,
        is_domestic: self.is_domestic,
        reporting_currency_id: self.get_reporting_currency.id,
        reporting_currency_code: self.get_reporting_currency.country_code,
        non_po_invoice_form_enabled: self.forms_enabled,
        form_enabled: self.forms_enabled
      }
      if self.forms_enabled
        attachment = self.form_custom_fields.where(field_key: "invoice_attachments").first&.attachments&.first&.attachment
        data[:invoice_attachment] = {
            url: attachment&.url,
            thumb: attachment&.url(:thumb),
            content_type: attachment&.content_type,
            file_name: attachment&.original_filename,
        }
      else
        data[:invoice_attachment] = {
            url: self.attachments.first&.file&.url(:original, timestamp: false),
            thumb: self.attachments.first&.file&.url(:thumb, timestamp: false),
            content_type: self.attachments.first&.file_content_type,
            file_name: self.attachments.first&.file_file_name
        }
      end
      data
    end
  end

  def return_tax_rate
    ori_value = (self.item_amounts_total.to_f - self.discount_amount&.value.to_f)
    tax_value = self.tax_amount&.value.to_f
    calci_tax_rate = (tax_value / ori_value) * 100
    precision_value(calci_tax_rate)
  end

  def invoice_discount_rate
    ((self.discount_amount&.value.to_f / self.item_amounts_total.to_f) * 100).round(2) rescue 0
  end

  def include_original_amount
    if self.invoice_items.present?
      precision_value(self.amount&.value)
    else
      precision_value(self.original_amount&.value)
    end
  end

  # For user role as invoice initiator
  def is_initiating_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:invoice_initiator), self)
  end

  # For user role as invoice reviewer
  def is_reviewing_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:invoice_reviewer), self) || user.vendor_payment_admin?
  end

  def is_crediting_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor), self)
  end

  ##### For Po Invoice, Non PO invoice, Agreement Invoice roles #####
  def is_po_initiating_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:po_invoice_initiator), self)
  end

  def is_po_reviewing_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:po_invoice_reviewer), self)
  end

  def is_po_auditing_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:po_invoice_auditor), self)
  end

  def is_non_po_initiating_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:non_po_invoice_initiator), self)
  end

  def is_non_po_reviewing_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:non_po_invoice_reviewer), self)
  end

  def is_non_po_auditing_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:non_po_invoice_auditor), self)
  end

  def is_agreement_invoice_initiating_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:agreement_invoice_initiator), self)
  end

  def is_agreement_invoice_reviewing_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:agreement_invoice_reviewer), self)
  end

  def is_agreement_invoice_auditing_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:agreement_invoice_auditor), self)
  end

  ############ End ############

  # def can_take_control?
  #   processing?
  # end

  def can_approve?
    processing? rescue false
  end

  def can_really_approve?
    user = user.present? ? user : RequestStore.store[:current_user]
    return false if user.blank?
    (processing? rescue false) && self.get_reviewers.include?(user)
    # if self.action_users(:take_control).include?(user)
    #   processing? rescue false
    # elsif self.action_users(:approve).include?(user)
    #   processing? rescue false
    # else
    #   false
    # end
  end

  def can_reject?
    processing? rescue false
  end

  def can_really_reject?
    user = user.present? ? user : RequestStore.store[:current_user]
    return false if user.blank?
    (processing? rescue false) && self.get_reviewers.include?(user)
    # if self.action_users(:take_control).include?(user)
    #   processing? rescue false
    # elsif self.action_users(:approve).include?(user) # If user can approve, they can also reject
    #   processing? rescue false
    # else
    #   false
    # end
  end

  def can_take_control?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    return false if user.blank?
    return false if self.action_users(:approve).include?(user)
    (processing? rescue false) && user.vendor_payment_admin? && (self.dlrms&.find_by(level_id: self.level&.id)&.taken_control_by_id != user.id rescue false)
  end

  def validate_if_auditor(user)
    policy = Policy.find_by id: self.policy_id
    if policy.present? && policy.policy_user_roles.present?
      policy.policy_user_roles.where(user_role_id: UserRole.id_for(:invoice_auditor), user_id: user.id).present? rescue false
    end
  end

  def validate_if_po_invoice_auditor(user)
    policy = Policy.find_by id: self.policy_id
    if policy.present? && policy.policy_user_roles.present?
      policy.policy_user_roles.where(user_role_id: UserRole.id_for(:po_invoice_auditor), user_id: user.id).present? rescue false
    end
  end

  def validate_if_po_invoice_reviewer(user)
    policy = Policy.find_by id: self.policy_id
    if policy.present? && policy.policy_user_roles.present?
      policy.policy_user_roles.where(user_role_id: UserRole.id_for(:po_invoice_reviewer), user_id: user.id).present? rescue false
    end
  end

  def validate_if_non_po_invoice_reviewer(user)
    policy = Policy.find_by id: self.policy_id
    if policy.present? && policy.policy_user_roles.present?
      policy.policy_user_roles.where(user_role_id: UserRole.id_for(:non_po_invoice_reviewer), user_id: user.id).present? rescue false
    end
  end

  def validate_if_non_po_invoice_auditor(user)
    policy = Policy.find_by id: self.policy_id
    if policy.present? && policy.policy_user_roles.present?
      policy.policy_user_roles.where(user_role_id: UserRole.id_for(:non_po_invoice_auditor), user_id: user.id).present? rescue false
    end
  end

  def self.role_based_initiator_associated_items(user, role_id, options = {})
    if [UserRole.id_for(:po_invoice_initiator), UserRole.id_for(:non_po_invoice_initiator), UserRole.id_for(:agreement_invoice_initiator)].include?(role_id)
      document_table_name = options[:document_table_name]
      if (document_table_name == "invoices") || ("#{self.table_name}" == "invoices")
        document_table_name = 'inward_invoices'
      end
      document_table_name.present? ? user.send("#{document_table_name}") : user.send("#{self.table_name}")
    elsif role_id == UserRole.id_for(:bank_payment_request_initiator)
      policy_ids = PolicyUserRole.select(:policy_id).where(user_id: user.id, user_role_id: role_id)
      user.company.inward_invoices.where(policy_id: policy_ids).where(invoice_status_id: finance_associated_status_ids)
    elsif [UserRole.id_for(:credit_note_initiator), UserRole.id_for(:credit_note_reviewer)].include?(role_id)
      policy_ids = PolicyUserRole.select(:policy_id).where(user_id: user.id, user_role_id: role_id)
      user.company.inward_invoices.where(policy_id: policy_ids).where(invoice_status_id: finance_associated_status_ids)
    end
  end

  def invoice_bank_account
    user = self.created_by
    return user.present? ? user.company.bank_accounts.find_by_id(self.bank_account_id) : nil
  end

  # def get_invoice_provider_name
  #   self.procurement.present? && self.procurement.purchase_order.present? ? 'PoInvoiceProvider' : 'NonPoInvoiceProvider'
  # end

  def get_invoice_provider_name
    # if self.procurement.present? && self.procurement.purchase_order.present?
    if self.procurement&.purchase_order.present?
      'PoInvoiceProvider'
    elsif self.payment_agreement_id.present?
      'AgreementInvoiceProvider'
    else
      'NonPoInvoiceProvider'
    end
  end

  def get_default_provider
    # if self.procurement.present? && self.procurement.purchase_order.present?
    #   "PoInvoiceProvider"
    # else
    #   "NonPoInvoiceProvider"
    # end
    get_invoice_provider_name
  end

  def update_net_amount_value
    # taxable_amt = self.items
    # tds_percentage = self.tds_slab&.tds
    # net_value = taxable_amt - (taxable_amt*tds_percentage.to_f/100)
    # if self.net_amount.present?
    #   self.net_amount.update(value: net_value)
    # else
    #   self.create_net_amount(value: net_value, currency_id: 1)
    # end
  end

  # def update_taxable_and_orig_amount_value
  #   taxable_val = []
  #   raw_val = []
  #   if self.items.present?
  #     self.items.each do |item|
  #       rate = item.rate
  #       quantity = item.quantity
  #       discount_percentage = item.discount
  #       amount_before_discount = rate*quantity
  #       taxable_amt = amount_before_discount - (amount_before_discount*discount.to_f/100)
  #       raw_val << amount_before_discount
  #       taxable_val << taxable_amt
  #     end
  #   end

  #   if self.original_amount.present?
  #     self.original_amount.update(value: raw_val.sum)
  #   else
  #     self.create_original_amount(value: raw_val.sum, currency_id: 1)
  #   end

  #   if self.taxable_amount.present?
  #     self.taxable_amount.update(value: taxable_val.sum)
  #   else
  #     self.create_taxable_amount(value: taxable_val.sum, currency_id: 1)
  #   end
  # end

  def generate_sequential_id?
    invoice_status_id != InwardInvoiceStatus.id_for(:open)
  end

  def amount_before_tax
    self.forms_enabled ? self.invoice_gross_amount.to_f : self.gross_amount&.value.to_f
  end

  def amount_after_tax
    if self.rcm_enabled
      res = self.forms_enabled ? self.invoice_gross_amount.to_f : self.gross_amount&.value.to_f
    else
      res = self.forms_enabled ? (self.invoice_gross_amount.to_f + self.invoice_tax_amount.to_f) : (self.gross_amount&.value.to_f + self.tax_amount&.value.to_f)
    end
    res
  end

  def invoice_payment_status
    payment_status_ids = self.payments.pluck(:payment_status_id)

    if (payment_status_ids & [PaymentStatus.id_for(:completed)]).any? && (payment_status_ids & PaymentStatus.status_ids_for_invoice_initiated).any?
      return InwardInvoiceStatus.where(id: InwardInvoiceStatus.ids_for([:partially_paid, :initiated])).as_json
    else
      return [self.invoice_status.as_json]
    end
  end

  def remaining_custom_field_config
    current_user = RequestStore.store[:current_user]
    invoice_cf_ids = self.custom_fields.pluck(:field_configuration_id)
    configurations = current_user.company.field_configurations.where.not(id: invoice_cf_ids).exclude_deleted.root_fields.order_created_at_desc
    custom_fields_config = configurations.with_parent_type(FieldParentType.id_for(:invoice))
    return custom_fields_config
  end

  def tds_per_item
    if forms_enabled
      (self.reporting_invoice_tds_amount.to_f / self.items.count.to_f) rescue 0
    else
      (self.tds_amount&.value.to_f / self.items.count.to_f) rescue 0
    end
  end

  def advance_per_item
    if forms_enabled
      (self.reporting_invoice_paid_outside_amount.to_f / self.items.count.to_f) rescue 0
    else
      (self.advance_amount&.value.to_f / self.items.count.to_f) rescue 0
    end
  end

  def display_tds_amount
    ((self.items.where(tds_applicable: true).map(&:item_taxable_amount).map(&:to_f).sum * self.tds_percentage.to_f) / 100).to_f.ceil
  end

  def cn_adjustment_per_item
    precision_value(self.invoice.credit_note_adjustments.joins(:amount).sum(:value) / self.items.count)
  end

  # Used for tracking completion %
  def review_pending?
    InwardInvoiceStatus.ids_for(:open, :retracted, :rejected).include?(invoice_status_id)
  end

  def review_completed?
    InwardInvoiceStatus.ids_for(:unpaid, :partially_paid, :paid, :approved, :auto_approved, :closed, :pending, :initiated, :voided).include?(invoice_status_id)
  end

  def review_in_progress?
    InwardInvoiceStatus.ids_for(:processing).include?(invoice_status_id)
  end

  def forms_extra_data(type = nil, entity_key = nil)
    if type.nil? || entity_key.nil?
      return {

      }
    end

    case entity_key
    when :policy_id, 'policy_id'
      data = {
        "id": policy_id,
        "name": policy&.name,
      }
    when :department_id, 'department_id'
      data = {
        "id": department_id,
        "department_code": department&.department_code,
        "name": department&.name,
      }
    when :cost_center_id, 'cost_center_id'
      data = {
        "id": cost_center_id,
        "name": cost_center&.name,
      }
    when :vendor_id, 'vendor_id'
      data = {
        "id": vendor_id,
        "vendor_id": vendor&.vendor_id,
        "vendor_sequence_id": vendor&.vendor_id,
        "name": vendor&.display_name,
        "trade_name": vendor&.trade_name
      }
    when :gstin_location_id, 'gstin_location_id'
      data = {
        "id": gstin_location_id,
        "gstin": gstin_location&.gstin,
        "name": gstin_location&.location,
        "address": gstin_location&.address
      }
    when :receiving_account_id, 'receiving_account_id'
      data = {
        "id": receiving_account_id,
        "name": receiving_account&.name,
        "account_number": receiving_account&.account_number,
        "ifsc": receiving_account&.ifsc
      }
    when :location_id, 'location_id'
      data = {
        "id": location_id,
        "name": location&.name,
        "location_code": location&.location_code
      }
    when :delivery_location_id, 'delivery_location_id'
      data = {
        "id": delivery_location_id,
        "name": delivery_location&.name,
        "location_code": delivery_location&.location_code
      }

    when :tds_slab_id, 'tds_slab_id'
      data = {
        "id": tds_slab_id,
        "name": "#{tds_slab&.tds}% - #{tds_slab&.name}",
        "tds": tds_slab&.tds
      }
    when :payment_term_id, 'payment_term_id'
      data = {
        "id": payment_term_id,
        "name": payment_term&.name,
        "description": payment_term&.description,
        "default": payment_term&.default
      }
    else
      data = {}
    end

    {
      "#{entity_key}_lookup_data": data,
      "#{entity_key}_choice_data": [data]
    }
  end

  def po_trail_item
    if procurement&.purchase_order.present?
      purchase_order_item_id = procurement.purchase_order.items.first.id
      BudgetTrail.find_by(entity_type: "PurchaseOrderItem", entity_id: purchase_order_item_id)
    end
  end

  def entity_date
    po_trail_item&.date || date
  end

  def entity_created_at
    po_trail_item&.entity_created_at&.to_date || created_at&.to_date
  end

  def entity_submitted_at
    po_trail_item&.entity_submitted_at&.to_date || submitted_at&.to_date || created_at&.to_date
  end

  def paid_amount
    payments.successful.joins(:amount).sum(:value).round(2)
  end

  def retrieve_value(entity)
    return tds_slab&.display_name if entity.entity_key == 'tds_slab_id'
    return get_discount_type if entity.entity_key == 'discount_type_id'
    return 'Awaiting approval' if entity.entity_key == 'invoice_status_id' && self.invoice_status_id == InwardInvoiceStatus.id_for(:processing) && can_really_approve?

    send("#{entity.entity_key.gsub('_id', '')}")&.name rescue send(entity.entity_key)
  end

  def get_discount_type
    if discount_type_id == 1
      'Percentage'
    else
      'Amount'
    end
  end

  def forms_enabled
    if RequestStoreUtil.current_user.blank?
      feature_flag_enabled = true
      po_feature_flag_enabled = true
    else
      feature_flag_enabled = NonPoInvoiceToggle.new(RequestStoreUtil.current_user).enabled?
      po_feature_flag_enabled = PoInvoiceToggle.new(RequestStoreUtil.current_user).enabled?
    end
    is_non_po_invoice = self&.invoice_type&.non_po_invoice? || false
    is_tax_invoice = self&.invoice_type&.tax_invoice? || false

    (feature_flag_enabled && is_non_po_invoice ) || ( po_feature_flag_enabled && is_tax_invoice && self.form_migrated)
  end

  def bank_payment_request_policies(user)
    role_filter = {}
    role_filter[:filter_role_id] = [UserRole.id_for(:bank_payment_request_initiator)]
    bank_payment_request_policies = Policy::VendorPayments::Index.(user, role_filter).policies rescue Policy.none
    bank_payment_request_policies
  end

  def invoice_budgets
    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: self, current_user: User.first})
    budgets = op["result"][:budgets]
    budgets
  end

  def invoice_budget_contributions_before_update
    if self.company.enforce_budget_configuration.enforce_invoice_budget?
      op = BudgetManager::BudgetLimitValidator::Invoice.({invoice: self, ignore_unbudgetables: true, current_user: self.created_by })

      op['result'][:budget_contributions] rescue {}
    end
    {}
  end

  def invoice_budget_limit_validation
    if self.company.enforce_budget_configuration.enforce_invoice_budget?
      return BudgetManager::BudgetLimitValidator::Invoice.({invoice: self, previous_budget_contributions: self.invoice_budget_contributions_before_update, current_user: self.company.users.first })
    end
  end

  def credit_notes_presence
    # return false for international invoice 
    return false unless self.is_domestic
    # if approved or beyound check if cnas is present 
    if InwardInvoiceStatus.ids_for_paid_amount_consideration.include?(self.invoice_status_id) && self.credit_note_adjustments.present?
      return true 
    elsif !InwardInvoiceStatus.ids_for_paid_amount_consideration.include?(self.invoice_status_id) && ( ( self.vendor.credit_notes.filter_adjustables.present? || self.credit_note_adjustments.present? ))
      return true 
    end
    return false
  end
  
  def remaining_adjustable_tds
    prev_adjusted_tds = self.procurement.invoices.where('created_at < ?', self.created_at).pluck(:adjusted_advance_tds).map(&:to_f).sum
    if self.advance_amount_required
      prev_adjusted_tds += self.adjusted_advance_tds
    end

    (self.po_advance_tds.to_f - prev_adjusted_tds).to_f
  end

  def po_advance
    self.advance_paid ? self.attributes['po_advance'] : 0
  end

  def remaining_adjustable_advance
    prev_adjusted_advance = self.procurement.invoices.where('created_at < ?', self.created_at).pluck(:adjusted_po_advance_payable_amount).map(&:to_f).sum
    if self.advance_amount_required
      prev_adjusted_advance += self.adjusted_po_advance_payable_amount
    end

    (self.po_advance.to_f - prev_adjusted_advance).to_f
  end

  def net_po_advance
    (self.po_advance.to_f + self.po_advance_tds.to_f).to_f rescue 0
  end

  def prev_adjusted_advance_tds
    self.procurement.invoices.where.not(id: self.id).where('created_at < ?', self.created_at).pluck(:adjusted_advance_tds).map(&:to_f).sum
  end

  def po_advance_tds
    advance_paid ? self.procurement.purchase_order&.po_advance_tds_amount.to_f : 0
  end

  def advance_paid
    self.procurement.purchase_order&.advance_payments.present?
  end

  private

  # def payment_agreement_updations
  #   parameters = RequestStore.store[:params]
  #   if parameters.present?
  #     general_invoices = parameters.dig(:payment_agreement, :general_invoices_attributes).present? rescue false
  #     rental_invoices = parameters.dig(:payment_agreement, :rental_invoices_attributes).present? rescue false
  #    if (general_invoices || rental_invoices)
  #       user = user.present? ? user : RequestStore.store[:current_user]
  #       update_creator(user)
  #       # update_company(user)
  #       # set_initial_status
  #     end
  #   end
  # end

  def set_initial_status
    self.update(invoice_status_id: InwardInvoiceStatus.id_for(:open))
  end

  # def set_invoice_type
  #   # This method is valid if there are multiple invoices of the same type
  #   parameters = RequestStore.store[:params]
  #   if parameters.present?
  #     general_invoices = parameters.dig(:payment_agreement, :general_invoices_attributes).present? rescue false
  #     rental_invoices = parameters.dig(:payment_agreement, :rental_invoices_attributes).present? rescue false
  #     if general_invoices
  #       self.update(invoice_type_id: InwardInvoiceType.id_for(:general_invoice))
  #     elsif rental_invoices
  #       self.update(invoice_type_id: InwardInvoiceType.id_for(:rental_invoice))
  #     end
  #   end
  # end

  def update_creator(user)
    self.created_by_user_id = user.id
  end

  def update_company(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    if user.present?
      if self.company_id.blank?
        self.company_id = user.company_id
      end
    end
  end

  def set_defaults
    if self.import_job_id.present?
      self.update(invoice_status_id: InwardInvoiceStatus.id_for(:open))
    end

    if self.invoice_status.blank?
      self.update(invoice_status_id: InwardInvoiceStatus.id_for(:unpaid))
      self.update_invoice_status
    end
  end

  def budget_trail_entry
    # as of now, no condition is being used to determine when to add the invoice to the budget trail
    if self.rejected? || self.voided?
      self.invoice_items.each do |invoice_item|
        BudgetManager::BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor.new.destroy_trail(invoice_item)
      end
    else
      self.invoice_items.each do |invoice_item|
        BudgetManager::BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor.new.save_trail(invoice_item)
      end
    end
  end

  def budget_trail_destroy
    self.invoice_items.each do |invoice_item|
      BudgetManager::BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor.new.destroy_trail(invoice_item)
    end
  end

  def self.status_ids(*statuses)
    status_ids = []
    statuses.each do |status|
      status_ids.push InwardInvoiceStatus.id_for(status)
    end

    status_ids.reject { |status_id| status_id.nil? }
  end

  def self.document_owner_attribute
    'created_by_user_id'
  end

  def self.document_status_attribute
    'invoice_status_id'
  end

  def self.document_status_class_name
    'InwardInvoiceStatus'
  end

  def self.finance_associated_status_ids
    InwardInvoiceStatus.ids_for(:unpaid, :partially_paid, :paid, :approved, :auto_approved, :closed, :initiated)
  end

  def self.auditor_associated_status_ids
    self.status_ids(:unpaid, :partially_paid, :paid, :retracted, :processing, :approved, :rejected, :auto_approved, :closed, :pending, :initiated)
  end

  def self.open_status_ids(user)
    InwardInvoiceStatus.ids_for([:open, :draft])
  end

  def self.role_based_associated_status_ids(user)
    InwardInvoiceStatus.ids_for(self.role_based_statuses(user))
  end

  def self.role_based_statuses(user)
    statuses = []
    if user.policy_user_roles.pluck(:user_role_id).uniq.present?
      user.policy_user_roles.pluck(:user_role_id).uniq.each do |role_id|
        if [UserRole.id_for(:po_invoice_initiator), UserRole.id_for(:non_po_invoice_initiator), UserRole.id_for(:invoice_initiator), UserRole.id_for(:agreement_invoice_initiator)].include?(role_id)
          statuses += [:unpaid, :partially_paid, :paid, :open, :retracted, :processing, :approved, :rejected, :auto_approved, :closed, :pending, :initiated]
        elsif [UserRole.id_for(:po_invoice_reviewer), UserRole.id_for(:non_po_invoice_reviewer), UserRole.id_for(:invoice_reviewer), UserRole.id_for(:agreement_invoice_reviewer)].include?(role_id)
          statuses += [:unpaid, :partially_paid, :paid, :retracted, :processing, :approved, :rejected, :auto_approved, :closed, :pending, :initiated]
        elsif UserRole.id_for(:admin) == role_id.to_i
          statuses += [:unpaid, :partially_paid, :paid, :open, :retracted, :processing, :approved, :rejected, :auto_approved, :closed, :pending, :initiated]
        end
      end
    end
    return statuses.uniq
  end

  def self.roles
    # [:admin, :purchase_order_initiator, :purchase_order_reviewer, :invoice_initiator, :invoice_reviewer, :goods_receiver]
    [
      :invoice_initiator,
      :invoice_reviewer,
      :invoice_auditor,
      :po_invoice_initiator,
      :po_invoice_reviewer,
      :po_invoice_auditor,
      :non_po_invoice_initiator,
      :non_po_invoice_reviewer,
      :non_po_invoice_auditor,
      :agreement_invoice_initiator,
      :agreement_invoice_reviewer,
      :agreement_invoice_auditor,
      :bank_payment_request_initiator,
      :bank_payment_request_reviewer,
      :bank_payment_request_creditor,
      :bank_payment_request_auditor,
      :credit_note_initiator,
      :credit_note_reviewer
    ]
  end

  def self.awaiting_records user
    user_id = user.id
    if user_id.present?
      where("#{table_name}.invoice_status_id": InwardInvoiceStatus.id_for(:processing)).awaiting_action_items(user_id)
    else
      self.none
    end
  end

  # def agreement_based_json
  #   {
  #     id: self.id,
  #     invoice_type: self.invoice_type&.name,
  #     department_attributes: { id: self.department_id, name: self.department&.name },
  #     location_attributes: { id: self.location_id, name: self.location&.name },
  #     cost_center_attributes: { id: self.cost_center_id, name: self.cost_center&.name },
  #     payment_term_attributes: {id: self.payment_term&.id, name: self.payment_term&.name},
  #     billing_type_attributes: {id: self.billing_type&.id, name: self.billing_type&.name},
  #     balance_due_attributes: {id: self.balance_due_id, value: precision_value(self.balance_due&.value), currency_id: self.amount&.currency_id},
  #     net_amount_attributes: {id: self.net_amount_id, value: precision_value(self.net_amount&.value), currency_id: self.net_amount&.currency_id},
  #     notify_users: self.notify_users&.as_json,
  #     vendor_attributes: {id: self.vendor_id, name: self.vendor&.display_name, business_name: self.vendor&.business_name},
  #     bank_account_attributes: {id: self.bank_account_id, name: invoice_bank_account&.name, account_number: invoice_bank_account&.account_number, ifsc: invoice_bank_account&.ifsc },
  #     vendor_location_attributes: { id: self.vendor_location_id, location: self.vendor_location&.location, gstin: self.vendor_location&.gstin, address: self.vendor_location&.address },
  #     vendor_locations: fetch_vendor_locations.as_json,
  #     bank_accounts: fetch_vendor_bank_accounts.as_json,
  #     note: self.note,
  #     tds_slab_attributes: { id: self.tds_slab_id, name: self.tds_slab&.name, tds: self.tds_slab&.tds },
  #     invoice_frequency_attributes: {id: self.invoice_frequency&.id, number: self.invoice_frequency&.number, period_id: self.invoice_frequency&.period_id },
  #     # payment_agreement_escalation_attributes: {id: self.payment_agreement_escalation_id, period_id: self.payment_agreement_escalation&.period_id, number: self.payment_agreement_escalation&.number, percentage_increment: self.payment_agreement_escalation&.percentage_increment },
  #     payment_agreement_escalations_attributes: self.payment_agreement_escalations.as_json,
  #     billing_start_date: self.billing_start_date&.to_date,
  #     billing_day_of_month: billing_day_of_month,
  #     due_date: self.due_date&.to_date,
  #     start_date: self.start_date,
  #     end_date: self.end_date,
  #     lock_in_period: self.lock_in_period,
  #     rent_free_period: self.rent_free_period,
  #     tenancy_period: self.tenancy_period,
  #     custom_fields: self.custom_fields

  #   }
  # end

  def payment_history_json
    {
      id: self.id,
      invoice_number: self.invoice_number,
      invoice_id: self.invoice_id,
      vendor_name: self.vendor&.display_name,
      due_date: self.due_date&.to_date,
      net_amount_attributes: { id: self.net_amount_id, value: precision_value(self.net_amount&.value), currency_id: self.net_amount&.currency_id },
      balance_due_attributes: { id: self.balance_due_id, value: precision_value(self.balance_due&.value), currency_id: self.amount&.currency_id },
      status: self&.status&.name&.titleize,
      creation_date: self.created_at.to_date,
      tds_slab_attributes: { id: self.tds_slab_id, name: self.tds_slab&.name, tds: self.tds_slab&.tds },
      agreement_type: self.class.name.underscore,
      payment_agreement_id: self.payment_agreement_id,
      vendor_id: self.vendor_id,
      agreement_number: self.payment_agreement&.get_agreement_number,
      procurement_id: self.procurement_id

    }
  end

  def fetch_vendor_locations
    self.vendor&.gstin_locations&.as_json
  end

  def fetch_vendor_bank_accounts
    self.vendor&.bank_accounts&.non_deleted&.as_json
  end

  # def payment_agreement_related_fields
  #   if self.payment_agreement.present?
  #     errors.add(:vendor, 'cannot be blank') if self.vendor_id.blank?
  #     errors.add(:vendor_location, 'cannot be blank') if self.vendor_location_id.blank?
  #     errors.add(:bank_account, 'name cannot be blank') if self.bank_account_id.blank?
  #     errors.add(:department, 'name cannot be blank') if self.department_id.blank?
  #     errors.add(:location, 'name cannot be blank') if self.location_id.blank?
  #     errors.add(:cost_center, 'name cannot be blank') if self.cost_center_id.blank?
  #     errors.add(:payment_term, 'name cannot be blank') if self.payment_term_id.blank?
  #     if self.billing_type_id == BillingType.id_for(:fixed_periodic) && (self.invoice_frequency.number.blank? || self.invoice_frequency.period_id.blank?)
  #       errors.add(:invoice_frequency, 'cannot be blank')
  #     end
  #   end
  # end

  # # This is used for agreement invoice custom fields
  # def set_custom_field_operation
  #   CustomField::SetFields.(self, FieldParentType.id_for(:invoice), reset_fields: true, save: true)
  # end

  # # This is used for agreement invoice custom fields
  # def after_update_custom_field_operation
  #   parameters = RequestStore.store[:params]
  #   if parameters.present?
  #     custom_fields = parameters&.dig(:custom_fields) || parameters&.dig(:invoice, :custom_fields)
  #   end
  # end

  # def validate_custom_fields_invoice
  #   set_fields = set_custom_fields_invoice self, custom_fields, false
  #   unless set_fields.success?
  #     add_message :error, set_fields.messages[:error]
  #     return
  #   end
  #   valid = CustomField::Validate.(self.invoice)
  #   unless valid.success?
  #     add_message :error, valid.messages[:error]
  #     return
  #   end
  # end

  def rollback_agreement_invoice
    if self.agreement_item.present?
      self.agreement_item.update(is_payment_agreement_upcoming_invoice: true)
    end
  end


  # # in case this invoice is paid or partially paid and the procurement it belongs to has a PO advance that has been initiated
  # # we need to mark that amount in the "paid_amount" attribute of each of the trail items of this invoice
  # # This will only apply in case it's an invoice raised as part of a PO
  # def handle_po_advance_budget_trails
  #   if self.tax_invoice? && (self.paid? || self.partially_paid?)
  #     # po = self.procurement.purchase_order
  #     # if po.payments.present?
  #     #   paid_amount = po.payments.successful.joins(:amount).sum(:value)
  #     #   payment_processing_amount = po.payments.payment_processing_bucket.joins(:amount).sum(:value)
  #     #   paid_percent_before_tax = paid_amount / self.amount_before_tax
  #     #   paid_percent_after_tax = paid_amount / self.amount_after_tax
  #     #   processing_percent_before_tax = payment_processing_amount / self.amount_before_tax
  #     #   processing_percent_after_tax = payment_processing_amount / self.amount_after_tax
  #     #   sql_before_tax = "UPDATE `budget_trails` SET `paid_amount_before_tax_value` = (#{paid_percent_before_tax} * billed_amount_before_tax_value)
  #     #                                           WHERE `budget_trails`.`id` IN (#{parent_trails.pluck(:id).join(",").to_s})"
  #     #   ActiveRecord::Base.connection.execute(sql_before_tax)
  #     #   sql_before_tax = "UPDATE budget_trails SET `payment_processing_amount_before_tax_value` = (#{processing_percent_before_tax} * billed_amount_before_tax_value)
  #     #                                         WHERE `budget_trails`.`id` IN (#{parent_trails.pluck(:id).join(",").to_s})"
  #     #   ActiveRecord::Base.connection.execute(sql_before_tax)
  #     #   sql_after_tax = "UPDATE `budget_trails` SET `paid_amount_after_tax_value` = (#{paid_percent_after_tax} * billed_amount_after_tax_value)
  #     #                                           WHERE `budget_trails`.`id` IN (#{parent_trails.pluck(:id).join(",").to_s})"
  #     #   ActiveRecord::Base.connection.execute(sql_after_tax)
  #     #   sql_after_tax = "UPDATE budget_trails SET `payment_processing_amount_after_tax_value` = (#{processing_percent_after_tax} * billed_amount_after_tax_value)
  #     #                                        WHERE `budget_trails`.`id` IN (#{parent_trails.pluck(:id).join(",").to_s})"
  #     #   ActiveRecord::Base.connection.execute(sql_after_tax)
  #     # end
  #   end
  # end

  # Syncs amounts from new forms structure to legacy amounts table

  def sync_amounts
    if forms_enabled
      # calculate the advance and adjusted tds
      self.skip_callback = true
      InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(RequestStore.store[:params], nil, self) if self.advance_amount_required && PoInvoiceToggle.new(RequestStoreUtil.current_user).enabled?
      base_currency_id = get_base_currency&.id

      if invoice_gross_amount.present?
        amounts_attributes_map.each do |key, value|
          # if an invoice has a payment associated with self, then do not update balance_payable, adding a workaround as balance payable do not get updated.
          next if self.payments.present? && key.to_s == 'invoice_balance_due'

          # if the payment is present, user can update the tds only from payment screen, ie from old to new tds structure
          if self.payments.present? && key.to_s == 'invoice_tds_amount'
            updated_values_to_new_structure
            next
          end


          amount_value = self.send(key)
          amount_attr = self.send("#{value}_id")
          if amount_attr.present?
            Amount.find_by(id: amount_attr).update(value: amount_value, currency_id: base_currency_id)
          else
            amount_id = Amount.create(value: amount_value, currency_id: base_currency_id).id
            self.send("#{value}_id=", amount_id)
          end
        end

        amount_direct_attribute_map.each do |key, value|
          amount_value = self.send(key)
          self.send("#{value}=", amount_value)
        end
        self.save
      end

      # FOR AMOUNT ATTRIBUTE
      amount_attr = self.amount_id
      # taxable + tax
      amount_value = self.invoice_taxable_amount.to_f + self.invoice_tax_amount.to_f
      if self.rcm_enabled
        amount_value = amount_value - self.invoice_tax_amount.to_f
      end

      self.skip_callback = true
      if amount_attr.present?
        Amount.find_by(id: amount_attr).update(value: amount_value, currency_id: base_currency_id)
      else
        amount_id = Amount.create(value: amount_value, currency_id: base_currency_id).id
        self.send("amount_id=", amount_id)
      end


      if self.payments.blank?
        # FOR NET AMOUNT
        net_amount_attr = self.net_amount_id
        # invoice_net_total_amount - invoice_paid_outside_amount
        # cant use invoice_net_amount because net amount converts to round value in new ui for base currency == 1
        net_amount_value = self.invoice_total_amount.to_f + self.invoice_paid_outside_amount.to_f - self.invoice_roundoff_amount.to_f
        self.skip_callback = true
        if net_amount_attr.present?
          Amount.find_by(id: net_amount_attr).update(value: net_amount_value, currency_id: base_currency_id)
        else
          amount_id = Amount.create(value: net_amount_value, currency_id: base_currency_id).id
          self.send("net_amount_id=", amount_id)
        end
      end
      if TaxType.where(tax_name: ['igst', 'cgst_sgst'] ).pluck(:id).include?(tax_type_id)
        self.gst_type_id = self.tax_type_id
      end
      # update attachments
      update_attachments
      self.save
      # update custom fields
    end
  end

  # def calculate_advance
  #   if self.advance_amount_required && self.forms_enabled
  #     unless self.class.name == 'OutwardInvoice'
  #       if self.advance_amount_required
  #         if self.procurement.invoices.count < 2
  #           # first invoice calculation
  #           adjusted_advance_tds = [self.invoice_tds_amount, self.po_advance_tds].min
  #           adjusted_po_advance_payable_amount = [self.invoice_balance_due, self.po_advance].min
  #           invoice_tds_amount = self.invoice_tds_amount - adjusted_advance_tds
  #           invoice_balance_due = [self.invoice_sub_total_amount - adjusted_po_advance_payable_amount - invoice_tds_amount, 0].max
  #         else
  #           # subsequent invoices
  #           adjusted_advance_tds = [self.invoice_tds_amount, self.remaining_adjustable_tds].min
  #           adjusted_po_advance_payable_amount = [self.invoice_balance_due, self.remaining_adjustable_advance].min
  #           invoice_tds_amount = self.invoice_tds_amount - adjusted_advance_tds
  #           invoice_balance_due = [self.invoice_sub_total_amount - adjusted_po_advance_payable_amount - invoice_tds_amount, 0].max
  #         end
  #         # update_params = {
  #         #   adjusted_advance_tds: adjusted_advance_tds,
  #         #   adjusted_po_advance_payable_amount: adjusted_po_advance_payable_amount,
  #         #   invoice_tds_amount: invoice_tds_amount,
  #         #   invoice_balance_due: invoice_balance_due
  #         # }
  #         self.update_column('adjusted_advance_tds', adjusted_advance_tds)
  #         self.update_column('adjusted_po_advance_payable_amount', adjusted_po_advance_payable_amount)
  #         self.update_column('invoice_tds_amount', invoice_tds_amount)
  #         self.update_column('invoice_balance_due', invoice_balance_due)
  #       end
  #     end
  #   end
  # end

  def sync_to_forms_structure
    amounts_attributes_map.each do |key, value|
      amount_value = self.send(value)&.value
      self.send("reporting_#{key}=", amount_value)
      self.send("#{key}=", amount_value)
    end
    amount_direct_attribute_map.each do |key, value|
      amount_value = self.send(value)
      self.assign_attributes({
                               "reporting_#{key}": amount_value,
                               "#{key}": amount_value
                             })
    end
    self.skip_callback = true
    self.save
  end

  def amounts_attributes_map
    # todo - I2P change it to converted values post multicurrency setup
    {
      invoice_taxable_amount: 'gross_amount',
      invoice_discount_amount: 'discount_amount',
      invoice_freight_amount: 'freight_amount',
      invoice_tax_amount: 'tax_amount',
      invoice_tds_amount: 'tds_amount',
      invoice_paid_outside_amount: 'advance_amount',
      invoice_balance_due: 'balance_due'
    }
  end

  def amount_direct_attribute_map
    {
      invoice_roundoff_amount: 'roundoff_amount'
    }
  end

  # def item_quantity_validation
  #   flag = false
  #   quantities = invoice_items.map(&:quantity).map(&:to_f)
  #   quantities.each do |quantity|
  #     flag = true if quantity <= 0
  #     break if flag
  #   end

  #   errors.add(:invoice_items, "quantity must be greater than 0") if flag
  # end

  # def item_rate_validation
  #   flag = false
  #   rates = invoice_items.map(&:rate).map(&:to_f)
  #   rates.each do |rate|
  #     flag = true if rate <= 0
  #     break if flag
  #   end

  #   errors.add(:invoice_items, "rate must be greater than 0") if flag
  # end

  def multiple_invoice_validation
    return true if self.invoice_type_id == InwardInvoiceType.id_for(:beneficiary)
    return true if InwardInvoiceStatus.ids_for( :rejected).include?(self.invoice_status_id)
    current_company_invoices = company.inward_invoices.scope_all_except_voided_rejected
    invoice_number = self.invoice_number
    vendor_id = self.vendor_id
    duplicate_invoices = current_company_invoices.with_invoice_number(invoice_number).with_vendor_ids(vendor_id).without_id(self.id)
    multiple_invoices = current_company_invoices.where(invoice_number: self.invoice_number).count > 1
    if invoice_number.present? && duplicate_invoices.present? && multiple_invoices
      errors.add(:inward_invoice, "There is a similar invoice added with the same invoice number in our records. Please re-check your invoice details.")
      return
    end
  end

  def updated_values_to_new_structure

    # update_tds
    old_tds_amount = self.invoice_tds_amount
    old_reporting_tds_amount = self.reporting_invoice_tds_amount

    tds_amount = self.tds_amount&.value&.to_f

    self.invoice_tds_amount = tds_amount
    self.reporting_invoice_tds_amount = (tds_amount.to_f * self.conversion_rate.to_f).round(2)
    self.tds_percentage = tds_slab&.tds.to_f
    # update tds for each line item also

    # self.items.each do |item|
    #   item_tds = item.item_tds_amount
    #   if item&.tds_applicable
    #     item_tds = ( item&.taxable_amount&.value.to_f * tds_slab&.tds.to_f ) / 100
    #     item.item_tds_amount = item_tds.to_f.round(2)
    #     item.reporting_item_tds_amount = (item_tds * self.conversion_rate.to_f).round(2)
    #   end
    #   item.save
    #   self.skip_callback = true
    # end


    # update invoice_total_amount
    self.invoice_total_amount = (self.invoice_total_amount.to_f + old_tds_amount.to_f - self.invoice_tds_amount.to_f).round(2)
    self.reporting_invoice_total_amount = (self.reporting_invoice_total_amount.to_f + old_reporting_tds_amount.to_f - self.reporting_invoice_tds_amount.to_f).round(2)

    # update invoice_net_total_amount
    self.invoice_net_total_amount = (self.invoice_net_total_amount.to_f + old_tds_amount.to_f - self.invoice_tds_amount.to_f).round(2)
    self.reporting_invoice_net_total_amount = (self.reporting_invoice_net_total_amount.to_f + old_reporting_tds_amount.to_f - self.reporting_invoice_tds_amount.to_f).round(2)

    # update invoice_balance_due
    self.invoice_balance_due = (self[:invoice_balance_due].to_f + old_tds_amount.to_f - self.invoice_tds_amount.to_f).round(2)
    self.reporting_invoice_balance_due = (self[:reporting_invoice_balance_due].to_f + old_reporting_tds_amount.to_f - self.reporting_invoice_tds_amount.to_f).round(2)

    # update

    self.skip_callback = true
    self.save
  end



  def update_attachments
    form_attachments_field = self&.form_custom_fields&.where(field_key: 'invoice_attachments').first
    if form_attachments_field.present?
      form_attachments_field.attachments.each do |new_attachment|
        old_attachment = self.attachments.find_or_initialize_by(file_file_name: new_attachment.attachment_file_name )
        next
        if old_attachment.new_record?
          old_attachment.file_file_name = new_attachment.attachment_file_name
          old_attachment.file_content_type = new_attachment.attachment_content_type
          old_attachment.file_file_size = new_attachment.attachment_file_size
          # old_attachment.file_file_size = new_attachment.attachment_file_size
          old_attachment.company_id = self.company_id
          old_attachment.procurement_document_id = form_attachments_field.document_id
          old_attachment.procurement_document_type = form_attachments_field.document_type
          old_attachment.user_id = RequestStoreUtil.current_user
          old_attachment.file = new_attachment.attachment
          old_attachment.save
        end
      end
    end
  end

  def set_currency_for_amount
    amount_attr = [:amount, :gross_amount, :net_amount, :tds_amount, :tax_amount, :discount_amount, :original_amount, :advance_amount, :freight_amount, :balance_due, :taxable_amount, :paid_amount, :remaining_amount]

    amount_attr.each do |amount_attribute|
      amount_attr_id = self.send("#{amount_attribute}_id")
      if amount_attr_id.present?
        Amount.find_by(id: amount_attr_id).update(currency_id: get_base_currency.id)
      end
    end
    self.skip_callback = true
    self.save
  end

  def budget_enabled?
    RequestStore.store[:current_company]&.feature_subscription&.budgeting_system || false
  end

  # def update_amount_after_cn_adjustment
  #   cna_added_amount = precision_value(self.credit_note_adjustments.joins(:amount).sum(:value))
  #   self.invoice_balance_due -= cna_added_amount
  #   self.reporting_invoice_balance_due = self.invoice_balance_due * conversion_rate
  #   self.invoice_credit_note_adjusted_amount = cna_added_amount
  #   self.save
  # end

  # We are keeping this aside for now.
  # def update_custom_fields
  #   form_custom_fields = self.form_custom_fields.where.not(field_key: 'invoice_attachments')

  #   form_custom_fields.each do |form_custom_field|
  #     if form_custom_field.entity_type == 'text'
  #       custom_field = self.custom_fields.find_or_initialize_by(field_key: form_custom_field.field_key)
  #       if custom_field.new_record?
  #         custom_field.parent_id = self.id
  #         custom_field.parent_type = "Invoice"
  #         custom_field.company_id = self.company_id

  #         field_configuration = custom_field.field_configuration.new()
  #         field_configuration.enabled           = true
  #         field_configuration.field_type_id     = FieldType.find_by(name: 'text').id
  #         field_configuration.mandatory         = form_custom_field.form_entity.required
  #         field_configuration.company_id        = self.company_id
  #         field_configuration.configurable_id   = self.company_id
  #         field_configuration.configurable_type = "Company"
  #         field_configuration.field_name        = form_custom_field.form_entity.label
  #         field_configuration.field_key         = form_custom_field.form_entity.entity_key
  #         field_configuration.save

  #       end
  #       custom_field.value = FieldText.create({ value: form_custom_field.value, company_id: self.company_id })
  #       custom_field.configured_field_value = form_custom_field.value
  #       custom_field.value_type = 'FieldText'

  #       custom_field.save

  #     elsif form_custom_field.entity_type == 'drop_down'
  #       custom_field = self.custom_fields.find_or_initialize_by(field_key: form_custom_field.field_key)

  #       if custom_field.new_record?
  #         custom_field.parent_id = self.id
  #         custom_field.parent_type = "Invoice"
  #         custom_field.company_id = self.company_id

  #         field_configuration = custom_field.field_configuration.new()
  #         field_configuration.enabled           = true
  #         field_configuration.field_type_id     = FieldType.find_by(name: 'drop_down').id
  #         field_configuration.mandatory         = form_custom_field.form_entity.required
  #         field_configuration.company_id        = self.company_id
  #         field_configuration.configurable_id   = self.company_id
  #         field_configuration.configurable_type = "Company"
  #         field_configuration.field_name        = form_custom_field.form_entity.label
  #         field_configuration.field_key         = form_custom_field.form_entity.entity_key
  #         field_configuration.save
  #       end
  #       value = form_custom_field.selection.form_entity_choice.name

  #       custom_field.value = FieldText.create({ value: form_custom_field.value, company_id: self.company_id })
  #       custom_field.configured_field_value = value
  #       custom_field.value_type = 'FieldDropDownSelection'

  #       custom_field.save
  #       end
  #     end
  #   end
  # end

end
