# == Schema Information
#
# Table name: purchase_orders
#
#  id                           :integer          not null, primary key
#  company_id                   :integer
#  procurement_id               :integer
#  location_id                  :integer
#  delivery_location_id         :integer
#  vendor_id                    :integer
#  payment_term_id              :integer
#  procurement_term_id          :integer
#  purchase_order_status_id     :integer
#  indent_number                :string(255)
#  indent_date                  :date
#  po_number                    :string(255)
#  override_po_number           :boolean
#  prefix                       :string(255)
#  sequence_start               :string(255)
#  delivery_date                :date
#  gst_type_id                  :integer
#  inclusive_of_taxes           :boolean
#  roundoff_total_enabled       :boolean
#  roundoff_amount              :decimal(10, 5)
#  transaction_amount_id        :integer
#  total_before_tax_id          :integer
#  tax_amount_id                :integer
#  total_after_tax_id           :integer
#  discount_amount_id           :integer
#  balance_amount_id            :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  user_id                      :integer
#  procurement_term_text        :text(16777215)
#  controlling_user_id          :integer
#  controlling_user_role_id     :integer
#  controlling_for_user_id      :integer
#  controlling_for_user_role_id :integer
#  policy_id                    :integer
#  controlling_level_id         :integer
#  department_id                :integer
#  is_deleted                   :boolean          default(FALSE), not null
#  cost_center_id               :integer
#  sub_department_id            :integer
#  billing_address              :text(16777215)
#  shipping_address             :text(16777215)
#  is_template                  :boolean          default(FALSE)
#  template_name                :string(255)
#  resource_template_id         :integer
#  deleted_at                   :datetime
#  submitted_at                 :datetime
#  approved_at                  :datetime
#  advance_amount_id            :integer
#  due_date                     :date
#  advance_amount_status_id     :integer
#  bank_account_id              :integer
#  revised_po_id                :integer
#  revision_of_id               :integer
#  revision_number              :integer          default(0)
#  note                         :text(65535)
#  advance_tds_slab_id          :integer
#  advance_tds_amount_id        :integer
#  advance_amount_required      :boolean          default(FALSE)
#  requested_advance_amount_id  :integer
#  gstin_location_id            :bigint
#  cost_allocation_items        :boolean          default(FALSE)
#  internal_note                :text(65535)
#  taxable_amount_id            :integer
#  vendor_address               :text(65535)
#  discount_type_id             :integer
#  vendor_poc_name              :string(255)
#  vendor_poc_email             :string(255)
#  vendor_poc_mobile_number     :string(255)
#  rejection_note               :text(65535)
#  vendor_poc_id                :integer
#  vlpm_id                      :integer
#  vendor_note                  :text(65535)
#  erp_sync_status_id           :integer
#  base_currency_id             :integer
#  reporting_currency_id        :integer
#

class PurchaseOrder < ApplicationRecord
  attr_accessor :skip_callback, :vendor_country_id_value
  include Templatable, Transitionable, MathUtil, CustomFieldFilterSupport, ControllingUser, GetCurrency
  include Concerns::ErpSyncConcern
  include LiquidDroppable
  include Exposures::Model::Exposable
  include Sequenced::ActsAsSequenced
  include FormsHelper
  include ErpSyncable
  include Searchkick::Api

  # # Multicurrency Support
  # include Monetizable
  acts_as_sequenced column: :po_number, purpose: :purchase_order, editable: false, prefix: 'PO/{fiscal_year_start}-{fiscal_year_end}/', min_length: 4

  alias_attribute :created_by_id, :user_id

  default_scope { order(po_number: :desc, created_at: :desc) }

  belongs_to :company, optional: true
  belongs_to :user, optional: true
  belongs_to :created_by, optional: true, foreign_key: 'user_id', class_name: 'User'
  belongs_to :procurement, optional: true
  belongs_to :location, optional: true, class_name: 'BranchLocation'
  belongs_to :delivery_location, optional: true, class_name: 'BranchLocation'
  belongs_to :vendor, optional: true, class_name: 'YesBankVendor'
  belongs_to :bank_account, optional: true
  belongs_to :payment_term, optional: true
  belongs_to :procurement_term, optional: true
  belongs_to :status, optional: true, class_name: 'PurchaseOrderStatus', foreign_key: :purchase_order_status_id
  belongs_to :purchase_order_status, optional: true, class_name: 'PurchaseOrderStatus'
  belongs_to :advance_amount_status, optional: true
  belongs_to :department, optional: true
  belongs_to :sub_department, optional: true, class_name: "Department", foreign_key: :sub_department_id
  belongs_to :cost_center, optional: true
  belongs_to :gst_type, optional: true
  belongs_to :vendor_country, optional: true, class_name: 'Country'
  belongs_to :base_currency, optional: true, class_name: 'Currency'
  belongs_to :reporting_currency, optional: true, class_name: 'Currency'

  belongs_to :controlling_user, optional: true, class_name: 'User'
  belongs_to :controlling_for_user, optional: true, class_name: 'User'
  belongs_to :controlling_user_role, optional: true, class_name: 'UserRole'
  belongs_to :controlling_for_user_role, optional: true, class_name: 'UserRole'

  belongs_to :total_before_tax, optional: true, class_name: "Amount"
  belongs_to :gross_amount, optional: true, class_name: "Amount", foreign_key: :total_before_tax_id

  belongs_to :tax_amount, optional: true, class_name: "Amount"
  belongs_to :total_after_tax, optional: true, class_name: "Amount"
  belongs_to :discount_amount, optional: true, class_name: "Amount", autosave: true
  belongs_to :balance_amount, optional: true, class_name: "Amount", autosave: true
  belongs_to :net_amount, optional: true, class_name: "Amount", foreign_key: :balance_amount_id
  # IF PO HAS ANY ADVANCE AMOUNT, WE ADD IT HERE
  belongs_to :requested_advance_amount, optional: true, class_name: "Amount"
  belongs_to :advance_amount, optional: true, class_name: "Amount"
  belongs_to :advance_tds_amount, optional: true, class_name: "Amount"
  belongs_to :advance_tds_slab, optional: true, class_name: 'TdsRatesList'
  belongs_to :revision_of, optional: true, class_name: 'PurchaseOrder'

  belongs_to :policy, optional: true
  belongs_to :level, optional: true, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id

  belongs_to :gstin_location, class_name: "GstinLocation", optional: true
  belongs_to :vendor_location, class_name: "GstinLocation", optional: true, foreign_key: :gstin_location_id

  has_many :document_level_reviewer_mappings, as: :document_reviewer_mappable

  has_many :attachments, class_name: "ProcurementAttachment", as: :procurement_document

  has_many :items, class_name: "PurchaseOrderItem", dependent: :destroy
  has_many :line_items, class_name: "PurchaseOrderItem", dependent: :destroy
  has_many :extra_charges, class_name: "ProcurementCharge", as: "Chargable"
  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable
  # has_many :custom_fields, as: :parent
  has_many :custom_fields, as: :parent, dependent: :destroy
  has_many :advance_payments, class_name: "Payment"

  has_many :payments, as: :parent

  has_many :trails, as: :parent
  has_many :purchase_request_items
  has_many :form_custom_fields, class_name: 'FormCustomField', as: :document, dependent: :destroy

  has_many :quotations, dependent: :destroy
  has_many :email_approvals, as: :documentable

  belongs_to :bank_account, optional: true

  has_paper_trail(
      meta: {
          parent_document_type: "Purchase Order",
          document_number: Proc.new { |document| document.po_number }
      }
  )
  delegate :open?, :retracted?, :rejected?, :processing?, :approved?, :auto_approved?, :sent_to_vendor?, :vendor_confirmed?, :closed?, :voided?, :po_revised?, to: :status

  accepts_nested_attributes_for :items, :purchase_request_items, allow_destroy: true
  accepts_nested_attributes_for :total_before_tax, :tax_amount, :total_after_tax, :discount_amount, :balance_amount, :advance_amount, :requested_advance_amount
  accepts_nested_attributes_for :custom_fields
  # accepts_nested_attributes_for :requested_advance_amount
  # accepts_nested_attributes_for :advance_payments

  validates :purchase_order_status_id, presence: true

  validate :item_quantity_validation
  validate :item_rate_validation

  # validates :policy_id, presence: true
  # validates :items, presence: true
  scope :with_company_id, -> (company_id) { where company_id: company_id }
  scope :document_number_generated_in_finly, -> { where override_po_number: [false, nil] }
  scope :not_open, -> { where.not purchase_order_status_id: PurchaseOrderStatus.id_for(:open) }
  scope :with_id, -> (id) { where id: id }
  scope :filter_ids, -> (id) { where id: id }
  scope :with_user_id, -> (user_ids) { where user_id: user_ids }
  scope :with_status_ids, -> (status_ids) {
    case status_ids
    when PurchaseOrderStatus::GROUP_OPEN
      # Open / Retracted
      where purchase_order_status_id: PurchaseOrderStatus.ids_for(:open, :retracted)
    when PurchaseOrderStatus::GROUP_AWAITING_APPROVAL
      # Awaiting Approval
      user_id = RequestStore.store[:current_user]&.id
      if user_id.present?
        where("#{table_name}.purchase_order_status_id": PurchaseOrderStatus.id_for(:processing)).awaiting_action_items(user_id)
      end
    when PurchaseOrderStatus::GROUP_APPROVED
      # Approved / Auto Approved
      where purchase_order_status_id: PurchaseOrderStatus.ids_for(:approved, :auto_approved)
    else
      where purchase_order_status_id: status_ids
    end
  }
  scope :with_grn_status_id, -> (status_id) {
    case status_id
    when 100
      # Due this week
      where 'purchase_orders.delivery_date between ? and ?', Date.today, Date.today.end_of_week
    when 101
      # Due this month
      where 'purchase_orders.delivery_date between ? and ?', Date.today, Date.today.end_of_month
    when 102
      # Overdue
      where 'purchase_orders.delivery_date < ?', Date.today
    when 103
      # Overdue
      where 'purchase_orders.delivery_date IS NULL OR purchase_orders.delivery_date > ?', Date.today.end_of_month
    else
      self.all
    end
  }
  scope :with_controlling_level_ids, -> (level_ids) { where controlling_level_id: level_ids }
  scope :with_controlling_user_id, -> (id) { where controlling_user_id: id }
  scope :with_procurement_id, ->(procurement_id) { where procurement_id: procurement_id }
  scope :filter_po_number, -> (po_number) { where('purchase_orders.po_number LIKE ?', "%#{po_number}%") }
  scope :with_vendor_ids, -> (ids) { where vendor_id: ids }
  scope :with_po_number, -> (po_number) { where po_number: po_number }
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
  scope :filter_delivery_location, -> (name) {
    if name.present?
      # joins(:delivery_location).where('name LIKE ?', "%#{name}%")
      joins(:delivery_location).where('branch_locations.name LIKE ? or branch_locations.address_1 LIKE ? or branch_locations.address_2 LIKE ? or branch_locations.pin LIKE ? or purchase_orders.shipping_address LIKE ?', "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%")
    end
  }
  scope :with_budgetable_user_ids, -> (user_ids) {
    if user_ids.present?
      where user_id: user_ids
    end
  }

  scope :with_budgetable_vendor_ids, -> (vendor_ids) {
    if vendor_ids.present?
      where vendor_id: vendor_ids
    end
  }
  # Used for generating document number
  scope :valid, -> {
    status_ids = [
        PurchaseOrderStatus.id_for(:processing),
        PurchaseOrderStatus.id_for(:rejected),
        PurchaseOrderStatus.id_for(:retracted),
        PurchaseOrderStatus.id_for(:approved),
        PurchaseOrderStatus.id_for(:auto_approved),
        PurchaseOrderStatus.id_for(:sent_to_vendor),
        PurchaseOrderStatus.id_for(:vendor_confirmed),
        PurchaseOrderStatus.id_for(:closed)
    ]
    where purchase_order_status_id: PurchaseOrderStatus.id_for(status_ids)
    # ids = pluck(:id)
    # ids = PurchaseOrderItem.where(purchase_order_id: ids).pluck(:purchase_order_id)
    # where(id: ids)
  }

  scope :filter_status_id, -> (status_ids) {
    with_status_ids(status_ids)
  }

  scope :filter_policy_id, -> (policy_id) { where policy_id: policy_id }
  scope :filter_location_id, -> (location_id) { where("location_id = ? OR delivery_location_id = ?", location_id, location_id) }
  scope :filter_cost_center_id, -> (cost_center_id) { where(cost_center_id: cost_center_id) }

  scope :filter_sub_department_id, -> (ids) {
    where sub_department_id: ids
  }

  scope :filter_department_id, -> (ids) {
    where department_id: ids
  }

  scope :filter_vendor_id, -> (ids) {
    where vendor_id: ids
  }

  scope :filter_user_id, -> (ids) {
    where user_id: ids
  }

  scope :filter_payment_term_id, -> (ids) {
    where payment_term_id: ids
  }

  scope :filter_base_currency, ->(ids) {
    where base_currency_id: ids
  }

  scope :filter_reporting_currency, ->(ids) {
    where reporting_currency_id: ids
  }

  scope :filter_payable_advances, -> {
    where(advance_amount_required: true,
          purchase_order_status_id: [
        PurchaseOrderStatus.id_for(:approved),
        PurchaseOrderStatus.id_for(:auto_approved),
        PurchaseOrderStatus.id_for(:sent_to_vendor),
        PurchaseOrderStatus.id_for(:vendor_confirmed)
    ],
          advance_amount_status_id: [
              AdvanceAmountStatus.id_for(:to_be_processed),
              AdvanceAmountStatus.id_for(:failed)
          ])
  }

  scope :filter_all_advances, -> {
    where.not(advance_amount_status_id: [nil, AdvanceAmountStatus.ids_for([:po_processing, :closed])], advance_amount_id: nil,
              purchase_order_status_id: [PurchaseOrderStatus.id_for(:closed), PurchaseOrderStatus.id_for(:po_revised),
                                         PurchaseOrderStatus.id_for(:processing), PurchaseOrderStatus.id_for(:voided),
                                         PurchaseOrderStatus.id_for(:rejected), PurchaseOrderStatus.id_for(:retracted),
                                         PurchaseOrderStatus.id_for(:open)
              ])
  }

  scope :show_only_po_which_have_advances, -> (show_it = false) {
    if StringUtils.to_bool(show_it)
      where(advance_amount_required: true, advance_amount_status_id: AdvanceAmountStatus.ids_for([:to_be_processed, :initiated, :paid, :failed, :pending, :po_processing, :closed]))
    end
  }

  scope :show_only_po_which_are_forwarded, -> (show_it = false) {
    if StringUtils.to_bool(show_it)
      self.joins(:document_level_reviewer_mappings).where('document_level_reviewer_mappings.forwarded is true')
    end
  }

  scope :filter_by_due_date, -> (due_date) {
    where due_date: due_date
  }

  scope :filter_by_created_at, -> (created_at) {
    created_at = Date.parse(created_at).strftime('%Y-%m-%d')
    # where created_at: created_at
    where("DATE(created_at) = ?", created_at)
  }

  scope :filter_po_advance_status, -> (status_name) {
    all_statuses = AdvanceAmountStatus.all.pluck(:name)
    if status_name.present? && all_statuses.include?(status_name)
      where advance_amount_status_id: AdvanceAmountStatus.id_for(status_name)
    end
  }

  scope :filter_status, -> (status_name) {
    case status_name
    when 'draft', :draft
      filter_status_id PurchaseOrder.status_ids(:open, :rejected, :retracted)
    when 'processing', :processing
      filter_status_id PurchaseOrderStatus.id_for(:processing)
    when 'approved', :approved
      filter_status_id PurchaseOrder.status_ids(:approved, :auto_approved)
    when 'sent_to_vendor', :sent_to_vendor
      filter_status_id PurchaseOrderStatus.id_for(:sent_to_vendor)
    when 'vendor_confirmed', :vendor_confirmed
      filter_status_id PurchaseOrderStatus.id_for(:vendor_confirmed)
    when 'closed', :closed
      filter_status_id PurchaseOrderStatus.id_for(:closed)
    when 'revised', :revised
      filter_status_id PurchaseOrderStatus.id_for(:po_revised)
    when 'voided', :voided
      filter_status_id PurchaseOrderStatus.id_for(:voided)
    when 'awaiting_approval', :awaiting_approval
      user_id = RequestStore.store[:current_user]&.id
      if user_id.present?
        ids = self.awaiting_action_items(RequestStore.store[:current_user]&.id)&.pluck(:id)
        with_id(ids)
      end
    else
      # all
    end
  }

  scope :filter_procurement_name, -> (name) {
    joins(:procurement).where("procurements.name LIKE ?", "%#{name}%")
  }

  scope :filter_creation_date_from, -> (creation_date) {
    date = Date.parse(creation_date) rescue nil
    if date
      where("created_at >= ?", date.beginning_of_day)
    end
  }

  scope :filter_creation_date_to, -> (creation_date) {
    date = Date.parse(creation_date) rescue nil
    if date
      where("created_at <= ?", date.end_of_day)
    end
  }

  scope :filter_submission_date_from, -> (submission_date) {
    date = Date.parse(submission_date) rescue nil
    if date
      where("submitted_at <= ?", date.beginning_of_day)
    end
  }

  scope :filter_submission_date_to, -> (submission_date) {
    date = Date.parse(submission_date) rescue nil
    if date
      where("submitted_at <= ?", date.end_of_day)
    end
  }

  scope :filter_awaiting_approval, -> (user = nil) {
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

  scope :filter_user, -> (user = nil) {
    if user.present? && user.instance_of?(User)
      user_id = user.id
    elsif user.instance_of?(TrueClass)
      user_id = RequestStore.store[:current_user]&.id
    else
      user_id = RequestStore.store[:current_user]&.id
    end

    if user_id.present?
      filter_user_id(user_id)
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


  # These two filters created because two different indexes requires data to be handled differently by design

  scope :due_date, -> (from, to) {
    from = Date.parse('01-01-1990') if from.blank?
    to = Date.today if to.blank?
    from = Date.parse(from) unless from.is_a?(Date)
    to = Date.parse(to) unless to.is_a?(Date)
    where('due_date >= ? && due_date <= ?', from, to)
  }

  scope :po_advances_date, -> (from, to) {
    from = Date.parse('01-01-1990') if from.blank?
    to = Date.today if to.blank?
    from = Date.parse(from) unless from.is_a?(Date)
    to = Date.parse(to) unless to.is_a?(Date)
    # nosqli - The incoming vars are substituted using AR's safe substitute
    where('created_at >= ? && created_at <= ?', from, to)
  }

  scope :filter_delivery_date, -> (delivery_date) { where 'delivery_date = ?', delivery_date }
  scope :exclude_revision_of_po, -> { where(revision_of_id: nil) }

  scope :includes_for_index, -> {
    includes(:user, :balance_amount, :vendor, :status, procurement: [:status_tags])
  }

  # Sorting
  scope :sort_po_number, -> (type) {
    type = type&.strip&.upcase
    # nosqli - The incoming var is checked to be ASC or DESC and then only substituted, not other value other than "ASC" or "DESC" possible
    if type && ['ASC', 'DESC'].include?(type)
      reorder("purchase_orders.po_number #{type}")
    end
  }

  scope :sort_po_name, -> (type) {
    type = type&.strip&.upcase
    if type && ['ASC', 'DESC'].include?(type)
      # nosqli - The incoming var is checked to be ASC or DESC and then only substituted, not other value other than "ASC" or "DESC" possible
      includes(:procurement).reorder("procurements.name #{type}")
    end
  }

  scope :filter_pr_number, -> (pr_number) {
    user = RequestStore.store[:current_user]
    if user.present?
      pr_item_ids = user.company.purchase_requests.where('purchase_requests.order_number LIKE ?', "%#{pr_number}%").joins(:purchase_request_items).pluck('purchase_request_items.id')
      joins(:items).where('purchase_order_items.purchase_request_item_id IN (?)', pr_item_ids)
    end
  }

  scope :filter_po_approver_id, -> (approver_id) {
    if approver_id.present?
      ids = self.select(:id).awaiting_action_items(approver_id)
      where(id: ids)
    end
  }

  # scope :sort_amount, -> (type){
  #   type = type&.strip&.upcase
  #   if type && ['ASC', 'DESC'].include?(type)
  #     includes(:balance_amount).reorder("amounts.value #{type}")
  #   end
  # }

  scope :pending_erp_sync, -> (*args) {
    with_erp_sync_status_pending.
        where(purchase_order_status_id: PurchaseOrderStatus.ids_for([ :released, :invoice_created, :received, :change_order, :approved, :auto_approved, :sent_to_vendor, :vendor_confirmed, :vendor_rejected ]))
  }

  scope :non_voided, ->{
    where.not(purchase_order_status_id: PurchaseOrderStatus.id_for(:voided))
  }

  # scope :includes_for_contract, -> {
  #   includes(:created_by, :invoice_type, :form_custom_fields, :items)
  # }

  before_save :calculate_line_items
  after_create :purchase_request_tasks
  after_save :sync_amounts, unless: :skip_callback
  after_save :set_currency_for_amount, unless: :skip_callback
  after_save :budget_trail_entry, if: :budget_enabled?
  after_destroy :budget_trail_destroy

  before_create :set_currency

  ransack_scopes :with_status_ids, :with_grn_status_id

  # backward compatible fields
  def po_balance_due
    forms_enabled ? self[:po_balance_due].to_f : self.balance_amount.value.to_f rescue 0
  end

  def reporting_po_balance_due
    forms_enabled ? self[:reporting_po_balance_due].to_f : self.balance_amount.value.to_f rescue 0
  end

  def po_sub_total_amount
    forms_enabled ? self[:po_sub_total_amount].to_f : self.total_after_tax.value.to_f rescue 0
  end

  def reporting_po_sub_total_amount
    forms_enabled ? self[:reporting_po_sub_total_amount].to_f : self.total_after_tax.value.to_f rescue 0
  end
  
  def set_currency
    self.reporting_currency_id = self.company.reporting_currency.id if self.reporting_currency_id.blank? 
    self.base_currency_id = self.company.reporting_currency.id if self.base_currency_id.blank? 
  end
  
  def status_tag_details
    return @tags_data if @tags_data.present?

    tag_ids = self.procurement&.status_tags&.pluck(:id) || []

    data = {
        grn: {},
        invoice: {},
        payment: {}
    }

    if tag_ids.include?(StatusTag.id_for(:payment_processed))
      data[:payment][:status] = 'completed'
      data[:payment][:status_text] = 'Payment Processed'
      data[:procurement_status_text] = "Procurement Complete"
    elsif tag_ids.include?(StatusTag.id_for(:payment_processing))
      data[:payment][:status] = 'processing'
      data[:payment][:status_text] = 'Payment Processing'
      data[:procurement_status_text] = 'Payment Processing'
    else
      data[:payment][:status] = 'init'
      data[:payment][:status_text] = 'Payment Pending'
      data[:procurement_status_text] = 'Payment Pending'
    end

    if tag_ids.include?(StatusTag.id_for(:shipment_received))
      data[:grn][:status] = 'completed'
      data[:grn][:status_text] = 'Shipment Received'
      data[:procurement_status_text] = 'Shipment Received'
    elsif tag_ids.include?(StatusTag.id_for(:receiving_shipment))
      data[:grn][:status] = 'processing'
      data[:grn][:status_text] = 'Receiving Shipment'
      data[:procurement_status_text] = 'Receiving Shipment'
    else
      data[:grn][:status] = 'init'
      data[:grn][:status_text] = 'Awaiting Shipment'
      data[:procurement_status_text] = 'Awaiting Shipment'
    end

    if tag_ids.include? StatusTag.id_for(:invoice_approved)
      data[:invoice][:status] = 'completed'
      data[:invoice][:status_text] = 'Invoice Approved'
      data[:procurement_status_text] = 'Awaiting Shipment'
    elsif (tag_ids.include? StatusTag.id_for(:invoice_processing)) || (tag_ids.include? StatusTag.id_for(:invoice_received))
      data[:invoice][:status] = 'processing'
      data[:invoice][:status_text] = 'Invoice Processing'
      data[:procurement_status_text] = 'Invoice Processing'
    else
      data[:invoice][:status] = 'init'
      if not self.procurement&.invoices.nil?
        data[:invoice][:status_text] = 'Invoice Processing'
        data[:procurement_status_text] = 'Invoice Processing'
      else
        data[:procurement_status_text] = 'Awaiting Invoice'
        data[:invoice][:status_text] = 'Awaiting Invoice'
      end
    end

    if PurchaseOrder.status_ids(:open, :retracted, :rejected).include?(self.purchase_order_status_id)
      data[:procurement_status_text] = "Awaiting PO Submission"
    elsif PurchaseOrder.status_ids(:processing).include?(self.purchase_order_status_id)
      data[:procurement_status_text] = "PO Processing"
    else
      # nothing
    end
    @tags_data = data
    data
  end


  template_config do
    include_association [:policy, :location, :delivery_location, :vendor,
                         :payment_term, :procurement_term, :department,
                         :sub_department, :cost_center]
    clone [:extra_charges, :items, :document_level_reviewer_mappings, :total_before_tax,
           :tax_amount, :total_after_tax, :discount_amount, :custom_fields]

    customize(lambda { |po, new_po|
      new_po.trails.destroy_all
      new_po.comments.destroy_all
      new_po.attachments.destroy_all
    })

    nullify :procurement_id
    nullify :po_number
    nullify :is_template
    nullify :template_name
    nullify :controlling_level_id
    nullify :controlling_user_id
    nullify :controlling_for_user_id
    nullify :controlling_user_role_id
    nullify :controlling_for_user_role_id
    nullify :balance_amount_id
    set :purchase_order_status_id => PurchaseOrderStatus.id_for(:open)
    nullify :user_id
  end

  template_merge :procurement_id, :user_id, :vendor_id

  def awaiting_action(user)
    return false if user.blank?
    self.get_reviewers.include? user
  end

  def all_items_shipped?
    shipped = true
    self.items.each do |item|
      unless item.quantity == item.accepted
        shipped = false
        break
      end
    end
    shipped
  end

  def all_items_accepted?(inward_document = nil)
    shipped = true
    self.items.each do |item|
      next if (item.inventory_line_item.product_type_id == ProductType.id_for(:service))
      # Commenting this fetch for value for now.
      # previously_delivered = inward_document.items.detect {|iw| iw if iw.purchase_order_item_id == item.id}.previously_delivered rescue 0
      unless item.quantity == (item.accepted + 0)
        shipped = false
        break
      end
    end
    shipped
  end

  def all_items_billed?
    billed = true
    self.items.each do |item|
      next if (item.inventory_line_item.product_type_id == ProductType.id_for(:goods))
      unless item.previously_billed_amount.to_f.round(2) == item.taxable_amount&.value.to_f.round(2)
        billed = false
        return
      end
    end
    billed
  end

  def partial_items_accepted?
    any_item = self.items.map { |item| item if (item.accepted > 0 || (item.inventory_line_item.product_type_id == ProductType.id_for(:service))) }.compact
    any_item.present?
  end


  def procurement_index_details
    {
        id: id,
        document_number: self.po_number,
        amount: self.balance_amount&.value,
        document_status: self.status&.name,
        document_owner: self.user&.name,
        document_type: self.class.name
    }
  end

  def can_unapprove?(user = nil)
    return false if user.blank?

    last_approve_trail = self.trails.only_approve.last
    last_retract_trail = self.trails.only_retract.last
    if last_approve_trail.present? && last_approve_trail.action_user.id == user.id
      if last_retract_trail.present? && last_retract_trail.created_at > last_approve_trail.created_at
        return false
      end
      return true
    else
      return false
    end
  end

  def can_approve?
    processing?
  end

  def can_really_approve?
    user = user.present? ? user : RequestStore.store[:current_user]
    return false if user.blank?
    processing? && self.get_reviewers.include?(user)
    # if self.action_users(:take_control).include?(user)
    #   processing?
    # elsif self.action_users(:approve).include?(user)
    #   processing?
    # else
    #   false
    # end
  end

  def can_reject?
    processing?
  end

  def can_really_reject?
    user = user.present? ? user : RequestStore.store[:current_user]
    return false if user.blank?
    processing? && self.get_reviewers.include?(user)
    # if self.action_users(:take_control).include?(user)
    #   processing?
    # elsif self.action_users(:approve).include?(user) # If user can approve, they can also reject
    #   processing?
    # else
    #   false
    # end
  end

  def can_take_control?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    return false if user.blank?
    return false if self.action_users(:approve).include?(user)
    processing? && user.vendor_payment_admin? && (self.dlrms&.find_by(level_id: self.level&.id)&.taken_control_by_id != user.id rescue false)
  end

  def advance_to_be_processed?
    self.advance_amount_status_id == AdvanceAmountStatus.id_for(:to_be_processed)
  end

  def advance_pending?
    self.advance_amount_status_id == AdvanceAmountStatus.id_for(:pending)
  end

  def advance_initiated?
    self.advance_amount_status_id == AdvanceAmountStatus.id_for(:initiated)
  end

  def advance_failed?
    self.advance_amount_status_id == AdvanceAmountStatus.id_for(:failed)
  end

  def advance_paid?
    self.advance_amount_status_id == AdvanceAmountStatus.id_for(:paid)
  end

  def advance_can_be_paid?
    advance_to_be_processed? || advance_failed?
  end

  def self.awaiting_records user
    user_id = user.id
    if user_id.present?
      where("#{table_name}.purchase_order_status_id": PurchaseOrderStatus.id_for(:processing)).awaiting_action_items(user_id)
    end
  end

  def advance_amount_status_empty
    self.advance_amount_status.blank?
  end

  def advance_closed?
    self.advance_amount_status_id == AdvanceAmountStatus.id_for(:closed)
  end

  def updatable?
    if (self.procurement.invoices.blank? && self.procurement.inward_documents.blank?)
      self.open? || self.processing?
    else
      false
    end
  end

  def document_owner?(user)
    self.user_id.eql?(user.id)
  end

  def total_adv_amount
    if user.po_form_enabled
      self.po_requested_advance_amount
    else
      (self.advance_amount&.value + self.advance_tds_amount&.value) rescue nil
    end
  end

  def entity_date
    created_at.to_date
  end

  def entity_created_at
    created_at.to_date
  end

  def entity_submitted_at
    submitted_at&.to_date || created_at&.to_date
  end

  # because somewhere we got 'as_json' for PO already. running on deadline. dont have time to remodify.
  def as_json2
    data={
        original_amount: precision_value(self.total_after_tax&.value),
        total_advance_amount: total_adv_amount,
        # advance_amount: precision_value(self.advance_amount&.value),
        payable_advance_amount: payable_advance_amount.round(2),
        reporting_payable_advance_amount: reporting_payable_advance_amount.to_f.round(2),
        balance_due: balance_due,
        conversion_rate: self.conversion_rate,
        procurement_id: self.procurement_id,
        tds_amount: user.po_form_enabled ? self.po_advance_tds_amount.to_f : self.advance_tds_amount&.value,
        tds: self.advance_tds_slab&.tds,
        tds_slab_id: self.advance_tds_slab_id,
        tds_slab_name: self.advance_tds_slab&.name,
        department: self.department.as_json,
        cost_center: self.cost_center.as_json,
        po_number: self.po_number,
        delivery_location: self.delivery_location.as_json,
        requested_advance_amount: user.po_form_enabled ? self.po_requested_advance_amount.to_f : self.requested_advance_amount&.value,
        purchase_order_total: user.po_form_enabled ? precision_value(self.po_balance_due) : precision_value(self.balance_amount&.value),
        editable: true,
        attachments: self.attachments.map(&:as_json),
        # since in FE as of now key name expected is invoice_attachment,
        # this should work out of the box for them
        invoice_attachment: {
            url: self.attachments.first&.file&.url(:original, timestamp: false),
            thumb: self.attachments.first&.file&.url(:thumb, timestamp: false),
            content_type: self.attachments.first&.file_content_type,
            file_name: self.attachments.first&.file_file_name
        },
        base_currency: get_base_currency,
        reporting_currency: get_reporting_currency,
        pr_forms_enabled: self.user.purchase_request_form_enabled,
        non_po_invoice_form_enabled: forms_enabled
        # balance_due: {
        #   value: precision_value(self.balance_amount&.value),
        #   id: self.balance_amount&.id,
        #   currency_id: self.balance_amount&.currency&.id
        # }
      }
    if self.forms_enabled
      attachment = self.form_custom_fields.where(field_key: "attachments").first&.attachments&.first&.attachment
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

  # Public Method

  def payable_advance_amount
    user.po_form_enabled ? (self.po_requested_advance_amount.to_f - self.po_advance_tds_amount.to_f) : precision_value(self.advance_amount&.value)
  end

  def reporting_payable_advance_amount
    user.po_form_enabled ? (self.payable_advance_amount.to_f * self.conversion_rate.to_f) : 0
  end

  def balance_due
    user.po_form_enabled ? precision_value(self.po_balance_due) : precision_value(self.balance_amount&.value)
  end

  def process_line_item_calculation(skip_adv_calculation = false)
    calculate_line_items(skip_adv_calculation)
  end

  def associate_purchase_request_items(options)
    user = options[:user]
    params = options[:params]
    item_ids = options[:item_ids]
    PurchaseRequestItem.with_ids(item_ids).update_all(purchase_order_id: self.id) unless item_ids.blank?
    copy_pr_item_to_po_item(item_ids, user)
  end

  def filter_purchase_request_item_ids(options, user)
    item_ids = []
    attributes = options.dig(:purchase_order, :purchase_request_items_attributes)
    attributes.each do |key, value|
      item_ids << attributes.dig(key, :id)
    end
    item_ids = item_ids.flatten.compact
    if item_ids.present?
      # Verify that item_ids belongs to the  company's PR
      filtered_item_ids = user.company.purchase_requests.joins(:purchase_request_items).where("purchase_request_items.id IN (?)", item_ids).pluck("purchase_request_items.id")
      return filtered_item_ids.uniq
    end
  end

  def get_form_based_next_sequence(seq_prefix)
    forms_enabled = PurchaseOrderToggle.new(RequestStoreUtil.current_user).enabled?
    return nil unless forms_enabled

    po_form_class_name = Forms::Router.klass(:purchase_orders)&.name

    po_form = Form.find_by(klass_name: po_form_class_name, company_id: self.company_id)
    return nil unless po_form.present?

    sequence_entity = (po_form.entities.where(type: 'FormEntity::AutoNumber').filter do |e|
      e.config.dig("sequence", "prefix") == seq_prefix
    end).first

    return nil unless sequence_entity.present?

    prefix, sequence = FormEntity::AutoNumber.fetch_autonumber(sequence_entity, self)
    prefix + sequence
  end


  # def prepopulate_amounts
  #   populate_advance_amount
  # end

  # For user role as purchase order initiator
  def is_initiating_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:purchase_order_initiator), self)
  end

  # For user role as purchase order reviewer
  def is_reviewing_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:purchase_order_reviewer), self)
  end

  def validate_if_auditor(user)
    if self.policy.present? && self.policy.policy_user_roles.present?
      self.policy.policy_user_roles.where(user_role_id: UserRole.id_for(:purchase_order_auditor), user_id: user.id).present? rescue false
    end
  end

  def generate_sequential_id?
    purchase_order_status_id != PurchaseOrderStatus.id_for(:open)
  end

  def purchase_order_number
    self.override_po_number.present? ? self.override_po_number : self.po_number
  end


  def amount_before_tax
    self.total_before_tax&.value
  end

  def amount_after_tax
    self.total_after_tax&.value
  end

  # Used for tracking completion %
  def review_pending?
    PurchaseOrderStatus.ids_for(:open, :retracted, :rejected).include?(purchase_order_status_id)
  end

  def review_completed?
    PurchaseOrderStatus.ids_for(:approved, :auto_approved, :sent_to_vendor, :closed, :voided, :po_revised, :vendor_confirmed).include?(purchase_order_status_id)
  end

  def review_in_progress?
    PurchaseOrderStatus.ids_for(:processing).include?(purchase_order_status_id)
  end
  
  def form_klass
    Forms::Router.klass(:purchase_orders)&.name
  end

  def retrieve_value(entity)  
    return get_discount_type if entity.entity_key == 'discount_type_id'
    return 'Awaiting approval' if entity.entity_key == 'purchase_order_status_id' && self.purchase_order_status_id == PurchaseOrderStatus.id_for(:processing) && can_really_approve?
    send("#{entity.entity_key.gsub('_id', '')}")&.name rescue send(entity.entity_key)
  end

  def get_discount_type
    if discount_type_id == 1
      'Percentage' 
    else
      'Amount'
    end
  end

  def po_budget_contributions_before_update
    if self.company.enforce_budget_configuration.enforce_purchase_order_budget?
      op = BudgetManager::BudgetLimitValidator::PurchaseOrder.({invoice: self, ignore_unbudgetables: true, current_user: self.created_by })
      op['result'][:budget_contributions] rescue {}
    end
    {}
  end

  def purchase_order_budgets
    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: self, current_user: User.first})
    budgets = op["result"][:budgets]
    budgets
  end

  def forms_enabled
    if RequestStoreUtil.current_user.blank?
      feature_flag_enabled = true
    else
      feature_flag_enabled = PurchaseOrderToggle.new(RequestStoreUtil.current_user).enabled?
    end
    feature_flag_enabled && self.form_migrated
  end

  def forms_flag_enabled
    RequestStoreUtil.current_user.blank? ? true : PurchaseOrderToggle.new(RequestStoreUtil.current_user).enabled?
  end

  def sync_amounts
    if forms_enabled
      self.skip_callback = true
      base_currency_id = get_base_currency&.id
      

      if self.procurement.invoices.count == 0

        amounts_attributes_map.each do |key, value|
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
      end
      self.save
    end
  end

  def amounts_attributes_map
    # todo - I2P change it to converted values post multicurrency setup
    {  
      po_discount_amount: 'discount_amount',
      po_taxable_amount: 'total_before_tax',
      po_tax_amount: 'tax_amount',
      po_sub_total_amount: 'total_after_tax',
      po_balance_due: 'balance_amount',

      # Purchase Order Advance
      # po_requested_advance_amount: 'requested_advance_amount',
      # po_advance_tds_amount: 'advance_tds_amount',
      # po_advance_amount: 'advance_amount'
    }
  end

  def amount_direct_attribute_map
    {
      po_roundoff_amount: 'roundoff_amount'
    }
  end

  def payment_ticket_policies(user)
    params = {}
    params[:filter_role_id] = UserRole.id_for(:bank_payment_request_initiator)
    result = Policy::VendorPayments::Index.(user, params)
    pt_policies = result.policies rescue Policy.none
    pt_policies
  end

  private

  def calculate_line_items(skip_adv_calculation = false, params = {})
    total_before_tax_amount = 0
    total_after_tax_amount = 0
    tax_amount = 0
    discount_amount = 0
    balance_amount = 0
    total_amount = 0
    persisted = false
    self.items.each do |item|
      if item.persisted?
        persisted = true
      end
      if item.is_a?(PurchaseOrderItem)
        item_quantity = (item.quantity || 0).to_f
        item_rate = (item.rate || 0).to_f
        item_amount = (item_quantity * item_rate)
        item_tax = (item.tax_rate&.rate || 0).to_f

        case self.discount_type_id
          # i.e. discount is given as a rate
        when 1
          item_discount = (item.discount || 0).to_f
          item_discount_amount = item_amount * item_discount / 100
        when 2
          item_discount_amount = item.discount || 0
        else
          item_discount = (item.discount || 0).to_f
          item_discount_amount = item_amount * item_discount / 100
        end

        # Exclusive of tax
        item_amount = (item_quantity * item_rate)
        # item_discount_amount = item_amount * item_discount / 100
        item_taxable_amount = item_amount - item_discount_amount
        item_tax_amount = item_taxable_amount * item_tax / 100
        item_total_amount = item_taxable_amount + item_tax_amount

        # Add to parent's amounts
        tax_amount += item_tax_amount
        discount_amount += item_discount_amount
        total_before_tax_amount += item_taxable_amount
        total_after_tax_amount += item_total_amount
        total_amount += item_total_amount

        # if persisted
        if item.tax_amount.present?
          item.tax_amount.value = item_tax_amount
        else
          item.tax_amount = Amount.new(value: item_tax_amount, currency_id: get_base_currency.id)
        end

        if item.taxable_amount.present?
          item.taxable_amount.value = item_taxable_amount
        else
          item.taxable_amount = Amount.new(value: item_taxable_amount, currency_id: get_base_currency.id)
        end

        # also set the CGST, SGST, and IGST amounts in the PO Line item
        case self.gst_type_id
          # i.e. it's a CGST + SGST case
        when GstType.id_for(:cgst_sgst)
          item.cgst = item_tax_amount / 2
          item.sgst = item_tax_amount / 2
          item.igst = 0
        when GstType.id_for(:igst)
          item.igst = item_tax_amount
          item.cgst = 0
          item.sgst = 0
        else
          item.igst = 0
          item.cgst = 0
          item.sgst = 0
        end

        if item.discount_amount.present?
          item.discount_amount.value = item_discount_amount
        else
          item.discount_amount = Amount.new(value: item_discount_amount, currency_id: get_base_currency.id)
        end

        if item.total_amount.present?
          item.total_amount.value = item_total_amount
        else
          item.total_amount = Amount.new(value: item_total_amount, currency_id: get_base_currency.id)
        end

        item.gl_code = item.category&.gl_code
        
      end

      calculate_item_total_amounts(item) if params[:associated_resource] == "purchase_request_item"
    end

    roundoff_amount = self.roundoff_amount.to_f
    if roundoff_amount != 0
      total_amount = precision_value (total_amount + roundoff_amount)
    else
      total_amount = precision_value total_amount
    end

    if self.total_before_tax.present?
      self.total_before_tax.value = total_before_tax_amount
    else
      self.total_before_tax = Amount.new(value: total_before_tax_amount, currency_id: get_base_currency.id)
    end


    if self.total_after_tax.present?
      self.total_after_tax.value = total_after_tax_amount
    else
      self.total_after_tax = Amount.new(value: total_after_tax_amount, currency_id: get_base_currency.id)
    end
    # if self.total_amount.present?
    #   self.total_amount.value = total_amount
    # else
    #   self.total_amount = Amount.new(value: total_amount, currency_id: 1)
    # end
    if self.discount_amount.present?
      self.discount_amount.value = discount_amount
    else
      self.build_discount_amount(value: discount_amount, currency_id: get_base_currency.id)
    end

    if self.tax_amount.present?
      self.tax_amount.value = tax_amount
    else
      self.build_tax_amount(value: tax_amount, currency_id: get_base_currency.id)
    end

    if self.balance_amount.present?
      self.balance_amount.value = total_amount&.round
    else
      self.build_balance_amount(value: total_amount&.round, currency_id: get_base_currency.id)
    end

    if self.requested_advance_amount.present? #&& self.advance_amount_status.id == AdvanceAmountStatus.id_for(:paid)
      # self.balance_amount.value = total_amount - self.advance_amount.value

      # handles a case when adv amount and tds slab is unchanged, dont recalculate.
      unless skip_adv_calculation
        tds = self.advance_tds_slab&.tds
        new_advance_amount = TaxCalculationUtils.tds_amount(self.requested_advance_amount.value, tds)
        tds_amount = self.requested_advance_amount.value - new_advance_amount
        # tds_amount = tds_amount.round(-1) # round the tds to the nearest 10. This is as per income tax rules to calculate tds, section 288b
        tds_amount = tds_amount.ceil # round the tds to the nearest digit as of now
        self.advance_tds_amount = Amount.create(value: tds_amount, currency_id: get_base_currency.id)
        final_advance_amount = self.requested_advance_amount.value - tds_amount
        if self.advance_amount.nil?
          self.advance_amount = Amount.create(value: final_advance_amount, currency_id: get_base_currency.id)
        else
          self.advance_amount.update(value: final_advance_amount)
        end
      end

    else
      self.advance_amount = Amount.new(value: 0, currency_id: get_base_currency.id)
      self.requested_advance_amount = Amount.new(value: 0, currency_id: get_base_currency.id)
    end
  end

  def budget_trail_entry
    if self.voided? || self.rejected?
      # this will delete the trails of all the items within this particular purchase order
      self.items.each do |item|
        BudgetManager::BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.destroy_trail(item)
      end
    else
      self.items.each do |item|
        BudgetManager::BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.save_trail(item)
      end
    end
  end

  def budget_trail_destroy
    self.items.each do |item|
      BudgetManager::BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.destroy_trail(item)
    end
  end

  def self.document_owner_attribute
    'user_id'
  end

  def self.document_status_attribute
    'purchase_order_status_id'
  end

  def self.document_status_class_name
    'PurchaseOrderStatus'
  end

  def self.status_ids(*statuses)
    status_ids = []
    statuses.each do |status|
      status_ids.push PurchaseOrderStatus.id_for(status)
    end

    status_ids.reject { |status_id| status_id.nil? }
  end

  def self.finance_associated_status_ids
    PurchaseOrderStatus.ids_for(:approved, :auto_approved, :sent_to_vendor, :vendor_confirmed, :closed, :voided)
  end

  def self.initiator_associated_status_ids
    PurchaseOrderStatus.ids_for(:approved, :auto_approved, :sent_to_vendor, :vendor_confirmed, :closed, :voided, :po_revised)
  end

  def self.auditor_associated_status_ids
    self.status_ids(:retracted, :rejected, :processing, :approved, :auto_approved, :sent_to_vendor, :vendor_confirmed, :closed, :voided, :po_revised)
  end

  def self.roles
    [
        :purchase_order_initiator,
        :purchase_order_reviewer,
        :purchase_order_auditor,
        :po_invoice_initiator,
        :bank_payment_request_initiator,
        :bank_payment_request_reviewer,
        :bank_payment_request_creditor,
        :bank_payment_request_auditor
    ]
  end

  def self.role_based_associated_status_ids(user)
    self.status_ids(*self.role_based_statuses(user))
    # PurchaseOrderStatus.ids_for(*self.role_based_statuses(user))
  end

  def self.open_status_ids(user)
    PurchaseOrderStatus.ids_for([:open, :draft])
  end

  def self.role_based_statuses(user)
    statuses = []
    if user.policy_user_roles.pluck(:user_role_id).uniq.present?
      user.policy_user_roles.pluck(:user_role_id).uniq.each do |role_id|
        if (UserRole.id_for(:purchase_order_initiator) == role_id.to_i)
          statuses += [:open, :retracted, :processing, :approved, :rejected, :auto_approved, :po_revised,:sent_to_vendor, :vendor_confirmed, :closed]
        elsif (UserRole.id_for(:purchase_order_reviewer) == role_id.to_i)
          statuses += [:processing, :approved, :auto_approved, :po_revised,:sent_to_vendor, :vendor_confirmed, :closed, :voided]
        elsif UserRole.id_for(:admin) == role_id.to_i
          statuses += [:processing, :approved, :rejected, :auto_approved, :po_revised,:sent_to_vendor, :vendor_confirmed, :closed, :voided]
        end
      end
    end
    return statuses.uniq
  end

  def self.initiator_associated_items(user, role_id)
    PurchaseOrder.where(id: user.procurements&.joins(:purchase_order)&.pluck("purchase_orders.id"))
  end

  def copy_pr_item_to_po_item(pr_item_ids, user)
    if PurchaseRequestItem.where(id: pr_item_ids).present?
      PurchaseRequestItem.where(id: pr_item_ids).each do |item|
        po_item_params = build_params_from_pr_item(item)
        create_purchase_order_item(po_item_params)
      end
    end
  end

  def build_params_from_pr_item(pr_item)
    item_hsn_sac = pr_item.hsn_sac.present? ? pr_item.hsn_sac : pr_item.item&.hsn_sac
    {
        # purchase_order_id: pr_item.purchase_order_id, inventory_line_item_id: pr_item.item_id, product_id: nil, description: pr_item&.item&.description, hsn_sac: pr_item&.item&.hsn_sac, quantity: pr_item.quantity, rate: pr_item&.item&.rate, tax: nil, tds: nil, discount: nil, tax_amount_id: nil, tds_amount_id: nil, discount_amount_id: nil, total_amount_id: pr_item.estimated_amount_id, delivery_date: nil, comment: nil, created_at: nil, updated_at: nil, delivered: 0, accepted: 0, rejected: 0, category_id: nil, cost_center_id: nil, is_deleted: false, account: nil, tax_rate_id: nil, deleted_at: nil, unit_of_measurement: nil

        purchase_order_id: pr_item.purchase_order_id, inventory_line_item_id: pr_item.item_id, product_id: nil, description: pr_item&.item&.description, hsn_sac: item_hsn_sac, quantity: pr_item.quantity, rate: pr_item&.per_unit_estimated_amount&.value, purchase_request_item_id: pr_item.id, tax_rate_id: pr_item&.item&.tax_rate_id, unit_of_measurement: pr_item.unit_of_measurement, department_id: pr_item.department_id, cost_center_id: pr_item.cost_center_id, category_id: pr_item.category_id, comment: pr_item.purpose, item_number: pr_item&.item&.item_number, product_type_id: pr_item&.item&.product_type_id
    }
  end

  def create_purchase_order_item(parameters)
    raise_unauthorized_exception unless PurchaseOrderItem.create!(parameters)
  end

  def purchase_request_tasks
    parameters = RequestStore.store[:params]
    if self.import_job_id.blank? && parameters[:associated_resource] == "purchase_request_item"
      # Initially when PO is created from PR, then cost allocation item is line_item by default
      update_po_cost_allocation_items
      item_ids = self.filter_purchase_request_item_ids(parameters, user)
      # Status transition of PR
      perform_status_transition({document_name: 'purchase_request', status_to: 'po_created', user: user, params: parameters, item_ids: item_ids})
      associate_purchase_request_items(params: parameters, user: user, item_ids: item_ids)
      self.reload
      calculate_line_items(true, parameters)
      calculate_summary_amounts
      self.save
    end
  end

  def perform_status_transition(options = {})
    user = options[:user]
    params = options[:params]
    case options[:status_to]
    when :po_created, 'po_created'
      item_ids = options[:item_ids]

      # Update Purchase request item statuses
      # TODO- create status change trail
      # PurchaseRequestItem.with_ids(item_ids).update_all(status_id: PurchaseRequestItemStatus.id_for(:po_created))
      PurchaseRequestItem.with_ids(item_ids).each do |purchase_request_item|
        purchase_request_item.status_id = PurchaseRequestItemStatus.id_for(:po_created)
        if purchase_request_item.save
          Trail.create(parent_type: 'PurchaseRequestItem', parent_id: purchase_request_item.id, action_user_id: user.id, action_id: TrailAction.id_for(:po_created))
        end
      end

      # document_ids = PurchaseRequestItem.with_ids(item_ids).pluck(:purchase_request_id) rescue nil
      # Status transition of PR to po_created if all of its line items are either rejected or issued_from_inventory or have PO created against them
      # document_ids.uniq.each do |document_id|
      #   purchase_request = user.company.purchase_requests.find_by_id document_id
      #   params[:document] = purchase_request
      #   params[:aasm_event] = 'po_creation'
      #   if purchase_request.purchase_request_items.approved.blank?
      #     op = WorkflowManager::Base.(user, params) if purchase_request.present?
      #     unless op.success? || purchase_request.present?
      #       add_message :error, op.messages[:error]
      #       raise_unauthorized_exception
      #     end
      #   end unless document_ids.blank?
      # end
    end
  end

  def self.role_based_initiator_associated_items(user, role_id, options = {})
    if UserRole.ids_for([:bank_payment_request_initiator, :po_invoice_initiator]).include? role_id
      policy_ids = PolicyUserRole.select(:policy_id).where(user_id: user.id, user_role_id: role_id)
      return user.company.purchase_orders.where(policy_id: policy_ids).where(purchase_order_status_id: initiator_associated_status_ids)
    end
    user.send("#{self.table_name}")
  end

  def update_po_cost_allocation_items
    self.update_column('cost_allocation_items', true)
  end

  def item_quantity_validation
    flag = false
    quantities = items.map(&:quantity).map(&:to_f)
    quantities.each do |quantity|
      flag = true if quantity <= 0
      break if flag
    end
    
    errors.add(:items, "quantity must be greater than 0") if flag
  end

  def item_rate_validation
    flag = false
    rates = items.map(&:rate).map(&:to_f)
    rates.each do |rate|
      flag = true if rate <= 0
      break if flag
    end
    
    errors.add(:items, "rate must be greater than 0") if flag
  end

  def set_currency_for_amount
    amount_attr = [:total_before_tax, :tax_amount, :total_after_tax, :discount_amount, :balance_amount, :requested_advance_amount, :advance_amount, :advance_tds_amount]

    amount_attr.each do |amount_attribute|
      amount_attr_id = self.send("#{amount_attribute}_id")
      if amount_attr_id.present?
        Amount.find_by(id: amount_attr_id).update(currency_id: get_base_currency.id)
      end
    end
    self.skip_callback = true
    self.save
  end

  # Amounts calculation on creating from PR items
  SUMMARY_ATTRIBUTES = {
    'po_discount_amount': 'discount_amount',
    'po_tax_amount': 'tax_amount',
    'po_sub_total_amount': 'total_after_tax',
    'po_balance_due': 'balance_amount',
    'po_taxable_amount': 'total_before_tax'
  }.freeze

  ITEM_ATTRIBUTES = {
    'item_discount_amount': 'discount_amount',
    'item_taxable_amount': 'taxable_amount',
    'item_tax_amount': 'tax_amount',
    'item_net_amount': 'total_amount'
  }.freeze

  def calculate_item_total_amounts(item)
    ITEM_ATTRIBUTES.each do |attr, value|
      item.send("#{attr}=", item.send(value)&.value)
      item.send("reporting_#{attr}=", reporting_currency_amount(item.send(value)&.value))
    end

    # values not available through associations
    item.item_gross_amount = item.item_taxable_amount + item.item_discount_amount
    item.reporting_item_gross_amount = item.reporting_item_taxable_amount + item.reporting_item_discount_amount
    item.item_rate = reporting_currency_amount(item.rate)
  end

  def calculate_summary_amounts
    SUMMARY_ATTRIBUTES.each do |attr, value|
      self.send("#{attr}=", self.send(value)&.value)
      self.send("reporting_#{attr}=", reporting_currency_amount(self.send(value)&.value))
    end

    # values not available through associations
    self.po_gross_amount = self.po_taxable_amount + self.po_discount_amount
    self.reporting_po_gross_amount = self.reporting_po_taxable_amount + self.reporting_po_discount_amount
  end

  def reporting_currency_amount(value)
    return (value.to_f * self.conversion_rate.to_f).round(2)
  end

  def budget_enabled?
    RequestStore.store[:current_company]&.feature_subscription&.budgeting_system || false
  end
end
