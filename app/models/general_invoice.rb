  # These are temporary invoices to get an idea what real invoice will be like. Payment are not made against them

  # Refer migration "AddColumnsToGeneralInvoices" for columns w.r.t invoices table
  # Make columns consistent with that in 'Invoices' table that this model acts as a template to actual "Invoice"

class GeneralInvoice < ApplicationRecord
  include SoftDeletable, MathUtil
  include Sequenced::ActsAsSequenced

  acts_as_sequenced column: :invoice_id, purpose: :invoice, editable: false, prefix: 'INV'

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
  belongs_to :vendor, optional: true, class_name: "YesBankVendor"
  belongs_to :location, optional: true, class_name: 'BranchLocation'
  belongs_to :procurement, optional: true, class_name: "Procurement"
  belongs_to :remaining_amount, optional: true, class_name: "Amount"
  belongs_to :gst_type, optional: true
  belongs_to :tds_slab, optional: true, class_name: 'TdsRatesList'
  belongs_to :payment_term, optional: true
  belongs_to :payment_agreement, optional: true
  belongs_to :department, optional: true
  belongs_to :sub_department, optional: true, class_name: 'Department', foreign_key: :sub_department_id
  belongs_to :gstin_location, class_name: "GstinLocation", optional: true
  belongs_to :billing_type, optional: true
  belongs_to :vendor_location, class_name: "GstinLocation", optional: true
  belongs_to :invoice_frequency, optional: true

  has_many :invoice_items, class_name: "InvoiceLineItem", as: :parent
  has_many :items, class_name: "InvoiceLineItem", as: :parent
  has_many :custom_fields, as: :parent, dependent: :destroy
  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable
  has_many :trails, as: :parent
  has_many :notify_users, as: :document


  alias_attribute :status, :invoice_status


  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :gross_amount
  accepts_nested_attributes_for :net_amount
  accepts_nested_attributes_for :discount_amount
  accepts_nested_attributes_for :tds_amount
  accepts_nested_attributes_for :tax_amount
  accepts_nested_attributes_for :original_amount
  accepts_nested_attributes_for :freight_amount
  accepts_nested_attributes_for :advance_amount
  accepts_nested_attributes_for :balance_due
  accepts_nested_attributes_for :invoice_items, allow_destroy: true
  accepts_nested_attributes_for :notify_users, allow_destroy: true
  accepts_nested_attributes_for :invoice_frequency



  delegate :tax_amount_value, to: :tax_amount
  delegate :tds_amount_value, to: :tds_amount
  delegate :discount_amount_value, to: :discount_amount
  delegate :net_amount_value, to: :net_amount
  delegate :gross_amount_value, to: :gross_amount
  delegate :paid_amount, to: :paid_amount


  attr_accessor :invoice_custom_fields



  validates :vendor, :vendor_location, :bank_account, :department, :location, :cost_center, :payment_term, :start_date, :end_date, :billing_type

  # validate :invoice_frequency_for_fix_periodic, :start_end_date_for_agreement


  def invoice_frequency_for_fix_periodic
    if self.billing_type_id == BillingType.id_for(:fixed_periodic) && (self.invoice_frequency.number.blank? || self.invoice_frequency.period_id.blank?)
      errors.add(:invoice_frequency, 'cannot be blank') 
    end
  end

  def start_end_date_for_agreement
    if self.start_date.present? && self.end_date.present?
      if self.payment_agreement.execution_date > self.start_date || self.payment_agreement.expiration_date < self.start_date
        errors.add(:start_date, ' should be between execution and expiration date')
      end
      if self.payment_agreement.execution_date > self.end_date || self.payment_agreement.expiration_date < self.end_date
        errors.add(:end_date, ' should be between execution and expiration date')
      end
    end
  end


end
