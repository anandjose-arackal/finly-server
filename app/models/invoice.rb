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
#  template_name                :string(255)      default("0")
#

#  gst_type_id: 1 - IGST
#              2 - CGST + SGST

class Invoice < ActiveRecord::Base
  include SoftDeletable, Templatable

  belongs_to :address
  belongs_to :amount
  belongs_to :gross_amount, class_name: "Amount"
  belongs_to :net_amount, class_name: "Amount"
  belongs_to :tds_amount, class_name: "Amount"
  belongs_to :tax_amount, class_name: "Amount"
  belongs_to :discount_amount, class_name: "Amount"
  belongs_to :original_amount, class_name: "Amount"
  belongs_to :advance_amount, class_name: "Amount"
  belongs_to :freight_amount, class_name: "Amount"
  belongs_to :balance_due, class_name: "Amount"
  belongs_to :taxable_amount, class_name: "Amount"
  belongs_to :category
  belongs_to :cost_center
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_user_id
  belongs_to :company
  belongs_to :invoice_status, class_name: "InwardInvoiceStatus"
  belongs_to :receiving_account, polymorphic: true
  belongs_to :vendor, class_name: "YesBankVendor"
  belongs_to :location, class_name: 'BranchLocation'
  belongs_to :delivery_location, class_name: 'BranchLocation'

  belongs_to :procurement, class_name: "Procurement"
  belongs_to :remaining_amount, class_name: "Amount"
  belongs_to :invoice_type, class_name: "InwardInvoiceType"
  belongs_to :gst_type
  belongs_to :tds_slab, class_name: 'TdsRatesList'
  belongs_to :payment_term

  belongs_to :controlling_user, class_name: 'User'
  belongs_to :controlling_for_user, class_name: 'User'
  belongs_to :controlling_user_role, class_name: 'UserRole'
  belongs_to :controlling_for_user_role, class_name: 'UserRole'

  belongs_to :department
  belongs_to :sub_department, class_name: 'Department', foreign_key: :sub_department_id

  belongs_to :policy
  belongs_to :level, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id

  has_many :document_level_reviewer_mappings, as: :document_reviewer_mappable

  # because multiple payments can be made against one invoice
  has_many :payments

  has_many :invoice_items, class_name: "InvoiceLineItem", as: :parent
  has_many :invoice_attachments

  # Attachments created for procurement
  has_many :attachments, class_name: "ProcurementAttachment", as: :procurement_document
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
  scope :with_cost_center_id, -> (id) {where cost_center_id: id}
  scope :with_controlling_level_ids, -> (level_ids) { where controlling_level_id: level_ids }
  scope :with_controlling_user_id, -> (id) {where controlling_user_id: id}
  scope :with_procurement_id, ->(procurement_id) {where procurement_id: procurement_id}
  scope :with_procurement, -> { where("invoices.procurement_id IS NOT NULL")}
  scope :with_vendor_ids, -> (ids) {where vendor_id: ids}


  scope :with_status_id, -> (status_id) {
    where invoice_status_id: status_id
  }

  scope :filter_payable_invoices, -> (enabled) {
    if StringUtils.to_bool(enabled)
      where(invoice_status_id: InwardInvoiceStatus.ids_for([:unpaid, :partially_paid]))
    end
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

  scope :created_at_desc, -> { order(created_at: :desc) }
  scope :created_at_asc, -> { order(created_at: :asc) }

  scope :with_cost_center_id, -> (id) {where cost_center_id: id}

  # scope :with_invoice_number, -> (invoice_number) {where 'invoice_number like ?', invoice_number}
  scope :filter_invoice_number, -> (invoice_number) {where 'invoices.invoice_number LIKE ?', "%#{invoice_number}%"}

  after_create :set_defaults

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

  def gst_type
    self.gst_type_id
  end

  def item_amounts_total
    if self.invoice_items.present?
      return self.invoice_items.joins(:amount).sum(:value)
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

  private

  def set_defaults
    if self.invoice_status.blank?
      self.update(invoice_status_id: InwardInvoiceStatus.id_for(:unpaid))
      self.update_invoice_status
    end
  end
end
