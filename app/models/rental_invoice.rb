# == Schema Information
#
# Table name: rental_invoices
#
#  id                                    :bigint           not null, primary key
#  address_id                            :integer
#  date                                  :date
#  due_date                              :date
#  invoice_number                        :text(65535)
#  tax_type_id                           :integer
#  discount                              :decimal(10, )
#  discount_type_id                      :integer
#  gross_amount_id                       :integer
#  net_amount_id                         :integer
#  inclusive_of_taxes                    :boolean
#  amount_id                             :integer
#  tds                                   :decimal(10, )
#  tds_type_id                           :integer
#  gst_type_id                           :integer
#  payment_id                            :integer
#  discount_amount_id                    :integer
#  tds_amount_id                         :integer
#  tax_amount_id                         :integer
#  tax                                   :decimal(10, )
#  category_id                           :integer
#  original_amount_id                    :integer
#  advance_amount_id                     :integer
#  advance_type_id                       :integer
#  advance                               :decimal(10, )
#  freight_amount_id                     :integer
#  freight_type_id                       :integer
#  freight                               :decimal(10, )
#  roundoff_amount                       :decimal(10, )
#  balance_due_id                        :integer
#  taxable_amount_id                     :integer
#  tds_slab_id                           :integer
#  invoice_status_id                     :integer
#  company_id                            :integer
#  created_by_user_id                    :integer
#  paid_amount_id                        :integer
#  receiving_account_id                  :integer
#  receiving_account_type                :string(255)
#  procurement_id                        :integer
#  remaining_amount_id                   :integer
#  invoice_type_id                       :integer
#  delivery_location_id                  :integer
#  sub_department_id                     :integer
#  policy_id                             :integer
#  is_template                           :boolean
#  template_name                         :string(255)
#  is_deleted                            :boolean
#  resource_template_id                  :integer
#  invoice_id                            :string(255)
#  deleted_at                            :datetime
#  gstin_location_id                     :integer
#  transaction_service_period_from       :date
#  transaction_service_period_to         :date
#  cost_allocation_items                 :boolean
#  narration                             :text(65535)
#  po_number                             :string(255)
#  payment_agreement_id                  :integer
#  bank_account_id                       :integer
#  vendor_location_id                    :integer
#  rejection_note                        :text(65535)
#  payment_agreement_escalation_id       :integer
#  invoice_frequency_id                  :integer
#  billing_start_date                    :datetime
#  billing_day_of_month                  :integer
#  payment_agreement_upcoming_date       :date
#  is_payment_agreement_upcoming_invoice :boolean
#  recurring_invoice_id                  :integer
#  vendor_poc_id                         :integer
#  vlpm_id                               :integer
#  client_note                           :text(65535)
#  start_date                            :date
#  end_date                              :date
#  lock_in_period                        :integer
#  rent_free_period                      :integer
#  tenancy_period                        :integer
#  vendor_id                             :integer
#  department_id                         :integer
#  location_id                           :integer
#  cost_center_id                        :integer
#  payment_term_id                       :integer
#  note                                  :text(65535)
#  billing_type_id                       :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  po_adjusted_advance                   :integer
#  po_advance                            :integer
#  po_prev_adjusted_advance              :integer
#  advance_amount_required               :boolean
#  proforma_invoice_id                   :integer
#  proforma_advance                      :integer
#  total_proforma_advance                :integer
#  template_invoice_id                   :integer
#  notice_period                         :integer
#  square_feet                           :decimal(10, 5)
#  prepaid                               :boolean
#  fixed_periodic_template               :boolean
#  escalation_percentage                 :float(24)
#  override_invoice_id                   :string(255)
#  rcm_enabled                           :boolean
#

class RentalInvoice < ApplicationRecord

  include SoftDeletable, MathUtil
  include Sequenced::ActsAsSequenced

  acts_as_sequenced column: :invoice_id, purpose: :rental_invoice, editable: false, prefix: 'RENINV'

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
  belongs_to :invoice_type, optional: true, class_name: "InwardInvoiceType"
  belongs_to :sub_department, optional: true, class_name: 'Department', foreign_key: :sub_department_id
  belongs_to :gstin_location, class_name: "GstinLocation", optional: true
  belongs_to :billing_type, optional: true
  belongs_to :vendor_location, class_name: "GstinLocation", optional: true
  belongs_to :invoice_frequency, optional: true
  belongs_to :delivery_location, optional: true, class_name: 'BranchLocation'
  belongs_to :template_invoice, optional: true, class_name: 'RentalInvoice'

  has_many :invoice_items, class_name: "InvoiceLineItem", as: :parent
  has_many :items, class_name: "InvoiceLineItem", as: :parent
  has_many :custom_fields, as: :parent, dependent: :destroy, autosave: true
  has_many :trails, as: :parent
  has_many :notify_users, as: :document
  has_many :invoices, as: :agreement_item

  # Use include_association instead of exclude_association if data tree grows
  #https://github.com/amoeba-rb/amoeba#installation

  amoeba do
    clone [:amount, :gross_amount, :net_amount, :tds_amount, :tax_amount, :discount_amount,
           :original_amount, :taxable_amount,
           :invoice_items, :custom_fields]#,
           #:document_level_reviewer_mappings]
    
    exclude_association :trails
    exclude_association :invoices
  end
  

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
  # accepts_nested_attributes_for :invoice_frequency



  delegate :tax_amount_value, to: :tax_amount
  delegate :tds_amount_value, to: :tds_amount
  delegate :discount_amount_value, to: :discount_amount
  delegate :net_amount_value, to: :net_amount
  delegate :gross_amount_value, to: :gross_amount
  delegate :paid_amount, to: :paid_amount


  attr_accessor :invoice_custom_fields

  validates :vendor, :vendor_location, :department, :location, :cost_center, :payment_term, :start_date, :end_date, :billing_type, presence: true
  # validates_inclusion_of :prepaid, in: [true, false]

  validate :additional_validations

  scope :template_invoices, -> { where(template_invoice_id: nil) }
  scope :with_billing_type, -> (billing_type_id){ where(billing_type_id: billing_type_id) }
  scope :fixed_periodic_type, -> { where(billing_type_id: BillingType.id_for(:fixed_periodic)) }
  scope :one_time_type, -> { where(billing_type_id: BillingType.id_for(:one_time)) }

  scope :filter_policy_id, -> (policy_id) {
    joins(:payment_agreement).where("payment_agreements.policy_id = ?", policy_id)
  } 
  scope :filter_vendor_id, -> (vendor_id) {
    where(vendor_id: vendor_id)
  }
  scope :filter_due_date, -> (due_date) {
    where(due_date: due_date&.to_date)
  }
  scope :filter_creation_date, -> (creation_date) {
    where(created_at: creation_date.to_date.beginning_of_day..creation_date.to_date.end_of_day)
  }
  scope :filter_from_date, -> (start_date) {
    where(start_date: start_date.to_date)
  }
  scope :filter_to_date, -> (end_date) {
    where(end_date: end_date.to_date)
  }

  # Columns mapped with actual invoice columns
  TEMPLATE_COLUMNS = %w{ date due_date tax_type_id discount discount_type_id inclusive_of_taxes tds tds_type_id gst_type_id payment_id tax category_id advance roundoff_amount tds_slab_id company_id created_by_user_id receiving_account_id receiving_account_type remaining_amount_id invoice_type_id delivery_location_id sub_department_id gstin_location_id payment_agreement_id bank_account_id vendor_location_id vendor_id department_id location_id cost_center_id payment_term_id billing_type_id advance_type_id }
  # Choose what columns to clone out of these template columns
  CLONE_RECORDS = %w{ discount_amount gross_amount net_amount amount original_amount balance_due taxable_amount  tds_amount tax_amount}


  def bank_account
    if self.receiving_account_type == "BankAccount"
      return self.receiving_account
    end
    nil
  end

  def invoice_bank_account
    user = self.created_by
    return user.present? ? user.company.bank_accounts.find_by_id(self.bank_account_id) : nil
  end

  def additional_validations
    errors.add(:bank_account, 'name cannot be blank') if self.bank_account_id.blank?
    errors.add(:invoice_items, ' cannot be blank') if self.invoice_items.blank?
  end

  def fetch_vendor_locations
    self.vendor&.gstin_locations&.as_json
  end

  def fetch_vendor_bank_accounts
    self.vendor&.bank_accounts&.non_deleted&.as_json
  end

  def set_creator_and_company(user)
    self.created_by_user_id = user.id if self.created_by_user_id.blank?
    self.company_id = user.company_id if self.company_id.blank?
  end



  def as_json(options={})
    if options[:payment_agreement]
      return agreement_based_json
    elsif options[:payment_history] || options[:upcoming_invoices]
      return payment_history_json
    end
  end

  def agreement_based_json
    {
      id: self.id, 
      invoice_type: self.invoice_type&.name,
      department_attributes: { id: self.department_id, name: self.department&.name },
      location_attributes: { id: self.location_id, name: self.location&.name },
      cost_center_attributes: { id: self.cost_center_id, name: self.cost_center&.name },
      payment_term_attributes: {id: self.payment_term&.id, name: self.payment_term&.name},
      billing_type_attributes: {id: self.billing_type&.id, name: self.billing_type&.name&.titleize},
      balance_due_attributes: {id: self.balance_due_id, value: precision_value(self.balance_due&.value), currency_id: self.amount&.currency_id},
      net_amount_attributes: {id: self.net_amount_id, value: precision_value(self.net_amount&.value), currency_id: self.net_amount&.currency_id},
      notify_users: self.notify_users&.as_json,
      vendor_attributes: {id: self.vendor_id, name: self.vendor&.display_name, business_name: self.vendor&.business_name, vendor_code: self&.vendor&.vendor_id, trade_name: self.vendor&.trade_name},
      bank_account_attributes: {id: self.bank_account_id, name: invoice_bank_account&.name, account_number: invoice_bank_account&.account_number, ifsc: invoice_bank_account&.ifsc },
      vendor_location_attributes: { id: self.vendor_location_id, location: self.vendor_location&.location, gstin: self.vendor_location&.gstin, address: self.vendor_location&.address },
      vendor_locations: fetch_vendor_locations.as_json,
      bank_accounts: fetch_vendor_bank_accounts.as_json,
      note: self.note,
      tds_slab_attributes: { id: self.tds_slab_id, name: self.tds_slab&.name, tds: self.tds_slab&.tds },
      invoice_frequency_attributes: get_invoice_frequency_attributes,
      billing_start_date: self.billing_start_date&.to_date,
      billing_day_of_month: billing_day_of_month,
      due_date: self.due_date&.to_date,
      start_date: self.start_date,
      end_date: self.end_date,
      lock_in_period: self.lock_in_period,
      rent_free_period: self.rent_free_period,
      tenancy_period: self.tenancy_period,
      custom_fields: self.custom_fields,
      notice_period: self.notice_period,
      square_feet: self.square_feet,
      already_exists: true,
      prepaid: self.prepaid,
      escalation_percentage: self.escalation_percentage,
      invoice_number: self.get_invoice_number
    }
  end

  def payment_history_json
    {
      id: self.id,
      invoice_number: self.get_invoice_number,
      vendor_name: self.vendor&.display_name,
      due_date: self.due_date&.to_date,
      net_amount_attributes: {id: self.net_amount_id, value: precision_value(self.net_amount&.value), currency_id: self.net_amount&.currency_id},
      balance_due_attributes: {id: self.balance_due_id, value: precision_value(self.balance_due&.value), currency_id: self.amount&.currency_id},
      status: self&.status&.name&.titleize,
      creation_date: self.created_at.to_date,
      tds_slab_attributes: { id: self.tds_slab_id, name: self.tds_slab&.name, tds: self.tds_slab&.tds },
      agreement_type: self.class.name.underscore,
      payment_agreement_id: self.payment_agreement_id,
      vendor_id: self.vendor_id,
      agreement_number: self.payment_agreement&.get_agreement_number,
      start_date: self.start_date,
      end_date: self.end_date

    }
  end

  # Quickfix as frontend was failing
  def get_invoice_frequency_attributes
    if self.billing_type.fixed_periodic?
      {id: self.invoice_frequency&.id, number: self.invoice_frequency&.number, period_id: self.invoice_frequency&.period_id }
    else
      {id: nil, number: nil, period_id: nil }
    end
  end

  def get_invoice_number
    self.override_invoice_id.present? ? self.override_invoice_id : self.invoice_id
  end


end
