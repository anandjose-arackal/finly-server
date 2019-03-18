# == Schema Information
#
# Table name: invoices
#
#  id                           :integer          not null, primary key
#  address_id                   :integer
#  date                         :date
#  due_date                     :date
#  invoice_number               :text(65535)
#  tax_type_id                  :integer
#  discount                     :decimal(64, 12)
#  discount_type_id             :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  gross_amount_id              :integer
#  net_amount_id                :integer
#  inclusive_of_taxes           :boolean
#  amount_id                    :integer
#  tds                          :decimal(64, 12)
#  tds_type_id                  :integer
#  gst_type_id                  :integer
#  payment_id                   :integer
#  discount_amount_id           :integer
#  tds_amount_id                :integer
#  tax_amount_id                :integer
#  tax                          :decimal(64, 12)
#  category_id                  :integer
#  original_amount_id           :integer
#  advance_amount_id            :integer
#  advance_type_id              :integer
#  advance                      :decimal(20, 10)
#  freight_amount_id            :integer
#  freight_type_id              :integer
#  freight                      :decimal(20, 10)
#  roundoff_amount              :decimal(20, 10)
#  balance_due_id               :integer
#  taxable_amount_id            :integer
#  cost_center_id               :integer
#  tds_slab_id                  :integer
#  invoice_status_id            :integer
#  company_id                   :integer
#  created_by_user_id           :integer
#  paid_amount_id               :integer
#  vendor_id                    :integer
#  receiving_account_id         :integer
#  receiving_account_type       :string(255)
#  note                         :text(65535)
#  procurement_id               :integer
#  remaining_amount_id          :integer
#  invoice_type_id              :integer
#  location_id                  :integer
#  delivery_location_id         :integer
#  payment_term_id              :integer
#  department_id                :integer
#  sub_department_id            :integer
#  policy_id                    :integer
#  controlling_level_id         :integer
#  controlling_user_id          :integer
#  controlling_user_role_id     :integer
#  controlling_for_user_id      :integer
#  controlling_for_user_role_id :integer
#  billing_address              :text(65535)
#  shipping_address             :text(65535)
#  is_template                  :boolean          default(FALSE)
#  template_name                :string(255)
#  is_deleted                   :boolean          default(FALSE)
#  resource_template_id         :integer
#  invoice_id                   :string(255)
#  deleted_at                   :datetime
#  submitted_at                 :datetime
#  approved_at                  :datetime
#

#  gst_type_id: 1 - IGST
#              2 - CGST + SGST

class Invoice < ApplicationRecord
  include SoftDeletable, Templatable, Transitionable, MathUtil

  include Sequenced::ActsAsSequenced

  acts_as_sequenced column: :invoice_id, purpose: :invoice, editable: false

  belongs_to :address, optional: true
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
  belongs_to :category, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :created_by, optional: true, class_name: "User", foreign_key: :created_by_user_id
  belongs_to :company, optional: true
  belongs_to :invoice_status, optional: true, class_name: "InwardInvoiceStatus"
  alias_attribute :status, :invoice_status
  belongs_to :receiving_account, optional: true, polymorphic: true
  belongs_to :vendor, optional: true, class_name: "YesBankVendor"
  belongs_to :location, optional: true, class_name: 'BranchLocation'
  belongs_to :delivery_location, optional: true, class_name: 'BranchLocation'

  belongs_to :procurement, optional: true, class_name: "Procurement"
  belongs_to :remaining_amount, optional: true, class_name: "Amount"
  belongs_to :invoice_type, optional: true, class_name: "InwardInvoiceType"
  belongs_to :gst_type, optional: true
  belongs_to :tds_slab, optional: true, class_name: 'TdsRatesList'
  belongs_to :payment_term, optional: true

  belongs_to :controlling_user, optional: true, class_name: 'User'
  belongs_to :controlling_for_user, optional: true, class_name: 'User'
  belongs_to :controlling_user_role, optional: true, class_name: 'UserRole'
  belongs_to :controlling_for_user_role, optional: true, class_name: 'UserRole'

  belongs_to :department, optional: true
  belongs_to :sub_department, optional: true, class_name: 'Department', foreign_key: :sub_department_id

  # belongs_to :policy, optional: true
  belongs_to :level, optional: true, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id

  has_many :document_level_reviewer_mappings, as: :document_reviewer_mappable

  # because multiple payments can be made against one invoice
  has_many :payments

  has_many :invoice_items, class_name: "InvoiceLineItem", as: :parent
  has_many :items, class_name: "InvoiceLineItem", as: :parent
  has_many :invoice_attachments

  # Attachments created for procurement
  has_many :attachments, class_name: 'ProcurementAttachment', as: :procurement_document
  has_many :custom_fields, as: :parent, dependent: :destroy

  # From Procurement workflow
  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable


  has_many :trails, as: :parent

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

  delegate :tax_amount_value, to: :tax_amount
  delegate :tds_amount_value, to: :tax_amount
  delegate :discount_amount_value, to: :discount_amount
  delegate :net_amount_value, to: :net_amount
  delegate :gross_amount_value, to: :gross_amount
  delegate :paid_amount, to: :paid_amount

  delegate :unpaid?, :partially_paid?, :paid?, :open?, :processing?, :rejected?,
           :approved?, :retracted?, :auto_approved?, :closed?, to: :invoice_status
  delegate :payment?, :advance?, to: :invoice_type


  # validates :gross_amount, presence: true
  # validates :net_amount, presence: true
  # validates :amount, presence: true

  scope :with_id, -> (id) {where id: id}
  scope :without_id, -> (id) { where.not(id: id) }
  scope :with_cost_center_id, -> (id) {where cost_center_id: id}
  scope :not_open, -> {where.not invoice_status_id: InwardInvoiceStatus.id_for(:open)}
  scope :with_controlling_level_ids, -> (level_ids) {where controlling_level_id: level_ids}
  scope :with_controlling_user_id, -> (id) {where controlling_user_id: id}
  scope :with_procurement_id, ->(procurement_id) {where procurement_id: procurement_id}
  scope :with_procurement, -> {where("invoices.procurement_id IS NOT NULL")}
  scope :with_vendor_ids, -> (ids) {where vendor_id: ids}
  scope :with_created_by_user_id, -> (user_ids) {where created_by_user_id: user_ids}
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


  scope :with_status_id, -> (status_id) {
    where invoice_status_id: status_id
  }

  scope :filter_payable_invoices, -> (enabled) {
    if StringUtils.to_bool(enabled)
      where(invoice_status_id: InwardInvoiceStatus.ids_for([:unpaid, :partially_paid]))
    end
  }

  scope :filter_department_id, -> (ids) {
    where department_id: ids
  }

  scope :filter_sub_department_id, -> (ids) {
    where sub_department_id: ids
  }

  scope :invoice_date, -> (from, to) {
    from = Date.parse('01-01-1990') if from.blank?
    to = Date.today if to.blank?
    from = Date.parse(from) unless from.is_a?(Date)
    to = Date.parse(to) unless to.is_a?(Date)
    where('date >= ? && date <= ?', from, to)
  }

  scope :due_date, -> (from, to) {
    from = Date.parse('01-01-1990') if from.blank?
    to = Date.today if to.blank?
    from = Date.parse(from) unless from.is_a?(Date)
    to = Date.parse(to) unless to.is_a?(Date)
    where('due_date >= ? && due_date <= ?', from, to)
  }

  scope :created_at_desc, -> {order(created_at: :desc)}
  scope :created_at_asc, -> {order(created_at: :asc)}

  scope :with_cost_center_id, -> (id) {where cost_center_id: id}

  # this scope checks for an exact match of invoice number
  scope :with_invoice_number, -> (invoice_number) {where invoice_number: invoice_number}

  # this scope checks for an approximate match - used in searches etc.
  scope :filter_invoice_number, -> (invoice_number) {where 'invoices.invoice_number LIKE ?', "%#{invoice_number}%"}
  scope :filter_invoice_id, -> (invoice_id) { where 'invoices.invoice_id like ?', "%#{invoice_id}%" }
  scope :filter_inward_invoice_type, -> (invoice_type){
    where invoice_type_id: InwardInvoiceType.id_for(invoice_type)
  }

  scope :filter_po_invoice, -> {
    where invoice_type_id: InwardInvoiceType.id_for(:tax_invoice)
  }

  scope :filter_non_po_invoice, -> {
    where invoice_type_id: InwardInvoiceType.id_for(:non_po_invoice)
  }

  scope :filter_invoice_type, -> (type) {
    case type
    when 'po_invoice'
      where invoice_type_id: InwardInvoiceType.id_for(:tax_invoice)
    when 'non_po_invoice'        
      where invoice_type_id: InwardInvoiceType.id_for(:non_po_invoice)
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

  scope :non_beneficiary, ->  {
    where(invoice_type_id: [InwardInvoiceType.id_for(:tax_invoice),
                            InwardInvoiceType.id_for(:advance),
                            InwardInvoiceType.id_for(:non_po_invoice),
                            nil])
  }

  scope :filter_by_created_at, -> (created_at) {
    created_at = Date.parse(created_at).strftime('%Y-%m-%d')
    # where created_at: created_at
    where("DATE(created_at) >= ?", created_at)
  }

  scope :filter_vendor_id, -> (ids){
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
        includes( :amount, :gross_amount, :net_amount, :tds_amount, :tax_amount, :discount_amount, :invoice_status, :tds_slab, :category,
           :original_amount, :freight_amount, :taxable_amount, :advance_amount, :balance_due, :cost_center, :gst_type, :receiving_account,
           :invoice_items, :invoice_attachments, :attachments, :custom_fields, invoice_items: [:amount, :discount_amount, :tax_amount, :net_amount, :taxable_amount, :tax_rate], vendor: [:bank_accounts], procurement: [:purchase_order], payments: [:amount])#.where(payments: {payment_status_id: PaymentStatus.id_for(:completed)})
  }

  scope :filter_user, -> (user=nil) {
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

  after_create :set_defaults
  after_save :budget_trail_entry
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

    customize(lambda { |invoice,new_invoice|
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

  def policy
    self.payment&.payment_order&.bank_payment_request&.policy
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
    self.tds
  end

  def discount_rate
    self.discount
  end

  def item_amounts_total
    if self.invoice_items.present?
      # return self.invoice_items.joins(:amount).sum(:value)
      return self.invoice_items.map {|p| p.amount.value}.sum
    else
      return 0
    end
  end

  def payment_amounts_total
    if self.payments.present?
      # return self.payments.successful.joins(:amount).sum(:value)
      return self.payments.map {|p| p.amount.value if (p.payment_status_id == PaymentStatus.id_for(:completed))}.compact.sum
    else
      return 0
    end
  end

  def item_quantity_total
    if self.invoice_items.present?
      # return self.invoice_items.sum(:quantity)
      return self.invoice_items.map {|p| p.quantity}.sum
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

  # this method updates the invoice status based on the associated
  # payments made against this particular invoice
  def update_invoice_status
    balance_due = self.balance_due&.value.to_f
    paid_amount = self.payments.successful.joins(:amount).sum(:value)

    if paid_amount == 0
      self.update(invoice_status_id: InwardInvoiceStatus.id_for(:unpaid))
    elsif paid_amount >= balance_due
      self.update(invoice_status_id: InwardInvoiceStatus.id_for(:paid))
    elsif paid_amount <= balance_due
      self.update(invoice_status_id: InwardInvoiceStatus.id_for(:partially_paid))
    end
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

  def generate_sequential_id?
    self.invoice_type_id == InwardInvoiceType.id_for(:non_po_invoice)
  end

  def as_json
    {
      id: self.id,
      advance: self.advance,
      advance_amount: self.advance_amount&.value,
      tax_amount: precision_value(self.tax_amount&.value),
      tds_amount: precision_value(self.tds_amount&.value),
      tax: precision_value(self.tax),
      tds: precision_value(self.tds),      
      gst_type_id: self.gst_type_id,
      tax_type_id: self.tax_type_id,
      tds_type_id: self.tds_type_id,
      discount_amount: precision_value(self.discount_amount&.value),
      discount: precision_value(self.discount),
      date: self.date,
      discount_type_id: self.discount_type_id,
      due_date: self.due_date,
      invoice_number: self.invoice_number,
      inclusive_of_taxes: self.inclusive_of_taxes,
      freight_amount: self.freight_amount&.value,
      roundoff_amount: self.roundoff_amount,
      net_payable_amount: self.balance_due&.value,
      balance_due: self.balance_due&.value,
      taxable_amount: precision_value(self.gross_amount&.value),
      editable: self.unpaid? || self.initiated?,
      tax_rate: precision_value(self.tax_rate),
      tds_rate: precision_value(self.tds_rate),
      discount_rate: precision_value(self.discount_rate),
      advance_rate: precision_value(self.advance_rate),
      invoice_attachment: {
        url: self.invoice_attachments.first&.attached_file&.url,
        thumb: self.invoice_attachments.first&.attached_file&.url(:thumb),
        content_type: self.invoice_attachments.first&.attached_file&.content_type,
        file_name: self.invoice_attachments.first&.attached_file&.original_filename
      },
      net_amount: precision_value(self.net_amount&.value),
      gross_amount: precision_value(self.gross_amount&.value),
      custom_fields: self.custom_fields,
      category_id: self.category_id,
      category_name: self.category&.name,

      cost_center_id: self.cost_center_id,
      cost_center_name: self.cost_center&.name,

      tds_slab_id: self.tds_slab_id,
      tds_slab_name: self.tds_slab&.name,
      tds_rate: self.tds,

      # invoice amounts total
      item_amounts_total: self.item_amounts_total,

      # paid amount for this invoice
      # paid_amount: self.payments.successful.joins(:amount).sum(:value),
      # remaining_amount: (self.balance_due&.value.to_f - self.payments.successful.joins(:amount).sum(:value))
      paid_amount: payment_amounts_total, 
      remaining_amount: (self.balance_due&.value.to_f - payment_amounts_total)
    }
  end

  # For user role as invoice initiator
  def is_initiating_user?(user=nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:invoice_initiator), self)
  end

  # For user role as invoice reviewer
  def is_reviewing_user?(user=nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:invoice_reviewer), self)
  end

  private

  def set_defaults
    if self.invoice_status.blank?
      self.update(invoice_status_id: InwardInvoiceStatus.id_for(:unpaid))
      self.update_invoice_status
    end
  end

  def budget_trail_entry
    # as of now, no condition is being used to determine when to add the invoice to the budget trail
    if self.open? || self.rejected? || self.retracted?
      self.invoice_items.each do |invoice_item|
        BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor.new.destroy_trail(invoice_item)
      end
    else
      self.invoice_items.each do |invoice_item|
        BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor.new.save_trail(invoice_item)
      end
    end
  end

  def budget_trail_destroy
    self.invoice_items.each do |invoice_item|
      BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor.new.destroy_trail(invoice_item)
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
    InwardInvoiceStatus.ids_for(:unpaid, :partially_paid, :paid, :approved, :auto_approved, :closed)
  end

  def self.role_based_associated_status_ids(user)
    InwardInvoiceStatus.ids_for(self.role_based_statuses(user))
  end

  def self.role_based_statuses(user)
    statuses = []
    if user.policy_user_roles.pluck(:user_role_id).uniq.present?
      user.policy_user_roles.pluck(:user_role_id).uniq.each do |role_id|
        if (UserRole.id_for(:invoice_initiator) == role_id.to_i)
          statuses += [:unpaid, :partially_paid, :paid, :open, :retracted, :processing, :approved, :rejected, :auto_approved, :closed, :pending]
        elsif (UserRole.id_for(:invoice_reviewer) == role_id.to_i)
          statuses += [:unpaid, :partially_paid, :paid, :retracted, :processing, :approved, :rejected, :auto_approved, :closed, :pending]
        elsif UserRole.id_for(:admin) == role_id.to_i
          statuses += [:unpaid, :partially_paid, :paid, :open, :retracted, :processing, :approved, :rejected, :auto_approved, :closed, :pending]
        end
      end
    end
    return statuses.uniq
  end

  def self.roles
    # [:admin, :purchase_order_initiator, :purchase_order_reviewer, :invoice_initiator, :invoice_reviewer, :goods_receiver]
    [:invoice_initiator, :invoice_reviewer]
  end

end
