# == Schema Information
#
# Table name: beneficiary_payments
#
#  id                              :bigint           not null, primary key
#  name                            :string(255)
#  vendor_id                       :integer
#  bank_account_id                 :integer
#  category_id                     :integer
#  department_id                   :integer
#  original_amount_id              :integer
#  tax_amount_id                   :integer
#  payable_amount_id               :integer
#  inclusive_of_taxes              :boolean
#  gst_type_id                     :integer
#  tax                             :decimal(10, 3)
#  tds_slab_id                     :integer
#  company_id                      :integer
#  sub_department_id               :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  status_id                       :integer
#  tds_amount_id                   :integer
#  balance_due_id                  :integer
#  net_amount_id                   :integer
#  gross_amount_id                 :integer
#  roundoff_amount                 :decimal(20, 10)
#  cost_center_id                  :integer
#  invoice_number                  :text(65535)
#  invoice_date                    :date
#  invoice_due_date                :date
#  advance_amount_id               :integer
#  payment_notification_users      :json
#  payment_agreement_id            :integer
#  note                            :string(255)
#  location_id                     :integer
#  vendor_location_id              :integer
#  tax_rate_id                     :integer
#  resource_template_id            :integer
#  creator_id                      :integer
#  payment_agreement_upcoming_date :date
#  uuid                            :string(36)
#  deleted_at                      :datetime
#

#                 :id => :integer,
#               :name => :string,
#          :vendor_id => :integer,
#    :bank_account_id => :integer,
#        :category_id => :integer,
#      :department_id => :integer,
# :original_amount_id => :integer,
#      :tax_amount_id => :integer,
#  :payable_amount_id => :integer,
# :inclusive_of_taxes => :boolean,
#        :gst_type_id => :integer,
#                :tax => :decimal,
#        :tds_slab_id => :integer,
#         :company_id => :integer,
#  :sub_department_id => :integer,
#         :created_at => :datetime,
#         :updated_at => :datetime,
#          :status_id => :integer,
#      :tds_amount_id => :integer,
#     :balance_due_id => :integer,
#      :net_amount_id => :integer,
#    :gross_amount_id => :integer,
#    :roundoff_amount => :decimal
#     :invoice_number => :text,
#       :invoice_date => :date,
#   :invoice_due_date => :date





class BeneficiaryPayment < ApplicationRecord
  include MathUtil, Templatable
  
  belongs_to :vendor,  class_name: 'YesBankVendor'
  belongs_to :bank_account, optional: true
  belongs_to :category, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :creator, optional: true, class_name: 'User'
  belongs_to :created_by, optional: true, class_name: "User", foreign_key: :created_by_user_id

  belongs_to :department, optional: true
  belongs_to :sub_department, optional: true, class_name: 'Department', foreign_key: :sub_department_id

  belongs_to :location, optional: true, class_name: "BranchLocation"
  belongs_to :vendor_location, optional: true, class_name: "GstinLocation"

  belongs_to :company, optional: true
  belongs_to :gst_type, optional: true
  belongs_to :tds_slab, optional: true, class_name: 'TdsRatesList'

  belongs_to :status, optional: true, class_name: 'BeneficiaryPaymentStatus'

  belongs_to :original_amount, optional: true, class_name: "Amount"
  belongs_to :tax_amount, optional: true, class_name: "Amount"
  belongs_to :payable_amount, optional: true, class_name: "Amount"
  belongs_to :balance_due, optional: true, class_name: "Amount"
  belongs_to :tds_amount, optional: true, class_name: "Amount"
  belongs_to :net_amount, optional: true, class_name: "Amount"
  belongs_to :gross_amount, optional: true, class_name: "Amount"
  belongs_to :advance_amount, optional: true, class_name: "Amount"
  belongs_to :payment_agreement, optional: true
  belongs_to :tax_rate, optional: true

  has_many :payments, as: :parent

  has_many :trails, as: :parent

  accepts_nested_attributes_for :original_amount
  accepts_nested_attributes_for :tax_amount
  accepts_nested_attributes_for :payable_amount
  accepts_nested_attributes_for :advance_amount

  # after_commit :calculate_tax_and_amount
  validate :payment_agreement_related_fields
  after_create :update_creator_id, :update_company_id, :update_status
  delegate :paid?, to: :status

  scope :with_id, -> (id) {where id: id}
  scope :without_id, -> (id) {where.not(id: id)}
  scope :only_unpaid, -> {where.not status_id: BeneficiaryPaymentStatus.id_for(:paid)}
  scope :only_paid, -> {where status_id: BeneficiaryPaymentStatus.id_for(:paid)}

  def tax_rate
  	self.tax
  end

  def unpaid?
    return nil if self.status.blank?
    return (self.status_id == BeneficiaryPaymentStatus.id_for(:unpaid))
  end

  def as_json(options={})
    if options[:payment_agreement]
      return agreement_based_json
    else
    	{
    	  id: self.id,
        tax_amount: precision_value(self.tax_amount&.value),
        tds_amount: precision_value(self.tds_amount&.value),
        tax: precision_value(self.tax),
        # tds: precision_value(self.tds),
        tds: precision_value(self.tds_slab&.tds),
        gst_type_id: self.gst_type_id,
        # tax_type_id: self.tax_type_id,
        # tds_type_id: self.tds_type_id,
        inclusive_of_taxes: self.inclusive_of_taxes,
        roundoff_amount: self.roundoff_amount,
        net_payable_amount: self.balance_due&.value,
        payable_amount_attributes: {id: self.payable_amount_id, value: self.payable_amount&.value, currency_id: self.payable_amount&.currency_id },
        balance_due: self.balance_due&.value,
        taxable_amount: precision_value(self.gross_amount&.value),
        editable: self.unpaid?,
        tax_rate: precision_value(self.tax_rate),
        tax_rate_id: self.tax_rate_id,
        tds_rate: precision_value(self.tds_slab&.tds),
        net_amount: precision_value(self.net_amount&.value),
        gross_amount: precision_value(self.gross_amount&.value),
        category_id: self.category_id,
        category_name: self.category&.name,
        # cost_center_id: self.cost_center_id,
        # cost_center_name: self.cost_center&.name,
        tds_slab_id: self.tds_slab_id,
        tds_slab_name: self.tds_slab&.name,
        # tds_rate: self.tds,
        paid_amount: self.payments.successful.joins(:amount).sum(:value),
        remaining_amount: (self.balance_due&.value.to_f - self.payments.successful.joins(:amount).sum(:value)),
        original_amount: precision_value(self.original_amount&.value),
        advance_amount: precision_value(self.advance_amount&.value),
        vendor_id: self.vendor_id,
        vendor_name: self.vendor&.name,
        vendor_location_id: self.vendor_location_id,
        vendor_location_attributes: { id: self.vendor_location_id, location: self.vendor_location&.location },
        department_attributes: { id: self.department_id, name: self.department&.name },
        location_attributes: { id: self.location_id, name: self.location&.name },
        cost_center_attributes: { id: self.cost_center_id, name: self.cost_center&.name },
        note: self.note,
        already_exists: true,
        payment_agreement_id: self.payment_agreement_id

    	}
    end
  end

  # private

  # this method should take the invoice, payment object and the params object and
  # assign the respective calculated amounts to the invoice object that is passed
  def calculate_tax_and_amount
  	original_amount = self.original_amount.value
  	net_amount = 0
  	tds_amount = 0
  	tax_amount = 0
  	balance_due_amount = 0

    if self.inclusive_of_taxes # calculate the other amounts retrospectively
      # first calculate the gross amount by deducting the discount from
      # the original amount entered
      # calculate_inclusive_taxes
      gross_amount = TaxCalculationUtils.inclusive_tax_amount(original_amount, (self.tax))
      tax_amount = original_amount - gross_amount
      # calculate_tds
      tds = self.tds_slab&.tds
      new_gross_amount = TaxCalculationUtils.tds_amount(gross_amount, tds)
      tds_amount = gross_amount - new_gross_amount
      # tds_amount = tds_amount.round(-1) # round the tds to the nearest 10. This is as per income tax rules to calculate tds, section 288b
      tds_amount = tds_amount.ceil # round the tds to the nearest digit as of now.
      # net_amount = gross_amount - tds_amount
      net_amount = self.original_amount.value - tds_amount - self.advance_amount&.value.to_f
    else # calculate proactively
      
      # calculate_exclusive_taxes
      net_amount = TaxCalculationUtils.exclusive_tax_amount(original_amount, (self.tax))
      tax_amount = net_amount - original_amount
      # calculate_tds
      tds = self.tds_slab&.tds
      new_gross_amount = TaxCalculationUtils.tds_amount(original_amount, tds)
      tds_amount = original_amount - new_gross_amount
      # tds_amount = tds_amount.round(-1) # round the tds to the nearest 10. This is as per income tax rules to calculate tds, section 288b
      tds_amount = tds_amount.ceil # round the tds to the nearest digit as of now.

      net_amount = original_amount + tax_amount - tds_amount - self.advance_amount&.value.to_f
    end


    self.roundoff_amount = self.roundoff_amount.to_f # even if it's nil, it gets converted to 0
    if self.roundoff_amount != 0
      balance_due_amount = precision_value (net_amount + self.roundoff_amount)
    else
      balance_due_amount = precision_value net_amount
    end

    # assign the respective calculated amounts to the payment and invoice object

    # assign invoice amount
    # if self.amount.present?
    #   self.amount.value = self.invoice_amount
    # else
    #   self.amount = Amount.new(value: self.invoice_amount, currency_id: 1)
    # end

    # assign gross amount
    if self.gross_amount.present?
      # self.gross_amount.value = gross_amount
      self.gross_amount.update(value: gross_amount)
    else
      self.gross_amount = Amount.new(value: gross_amount, currency_id: 1)
    end

    # assign tax amount
    if self.tax_amount.present?
      # self.tax_amount.value = tax_amount
      self.tax_amount.update(value: tax_amount)
    else
      self.tax_amount = Amount.new(value: tax_amount, currency_id: 1)
    end

    # assign TDS amount
    if self.tds_amount.present?
      # self.tds_amount.value = tds_amount
      self.tds_amount.update(value: tds_amount)
    else
      self.tds_amount = Amount.new(value: tds_amount, currency_id: 1)
    end

    # assign net amount
    if self.net_amount.present?
      # self.net_amount.value = net_amount
      self.net_amount.update(value: net_amount)
    else
      self.net_amount = Amount.new(value: net_amount, currency_id: 1)
    end

    # assign balance due
    if self.balance_due.present?
      # self.balance_due.value = balance_due_amount
      self.balance_due.update(value: balance_due_amount)
    else
      self.balance_due = Amount.new(value: balance_due_amount, currency_id: 1)
    end

    # quick fix for abp
    # payable amount has no definition in that document. just there for display purposes.
    if self.payable_amount.present?
      self.payable_amount.update(value: balance_due_amount)
    else
      self.payable_amount = Amount.new(value: balance_due_amount, currency_id: 1)
    end

    # # adding the payment amount to the params if  the object is present
    # self.payment_amount = payment_amount || balance_due_amount

    # if payment.present?
    #   if payment.amount.present?
    #     payment.amount.value = self.payment_amount
    #   else
    #     payment.amount = Amount.new(value: self.payment_amount, currency_id: 1)
    #   end
    # end
    # params
  end


  # def calculate_exclusive_taxes
  #   if self.tax.blank?
  #     self.net_amount = self.gross_amount
  #     self.tax_amount = 0
  #     return
  #   end
  #   self.net_amount = TaxCalculationUtils.exclusive_tax_amount(self.gross_amount, (self.tax))
  #   self.tax_amount = self.net_amount - self.gross_amount
  # end

  # def calculate_inclusive_taxes
  #   if self.tax.blank?
  #     self.gross_amount = self.original_amount
  #     self.tax_amount = 0
  #     return
  #   end
  #   
  #   self.gross_amount = TaxCalculationUtils.inclusive_tax_amount(self.original_amount, (self.tax))
  #   self.tax_amount = self.original_amount - self.gross_amount
  # end

  # def calculate_tds
  #   tds = self.tds_slab&.tds
  #   new_gross_amount = TaxCalculationUtils.tds_amount(self.gross_amount, tds)
  #   self.tds_amount = self.gross_amount - new_gross_amount
  # end

  def agreement_based_json(options={})
    {
      id: self.id,
      tax_amount: precision_value(self.tax_amount&.value),
      tds_amount: precision_value(self.tds_amount&.value),
      tax: precision_value(self.tax),
      tds: precision_value(self.tds_slab&.tds),
      vendor_attributes: {id: self.vendor_id, name: self.vendor&.name, business_name: self.vendor&.business_name, trade_name: self.vendor&.trade_name},
      bank_account_attributes: {id: self.bank_account_id, name: self.bank_account&.name, account_number: self.bank_account&.account_number, ifsc: self.bank_account&.ifsc },
      vendor_location_attributes: { id: self.vendor_location_id, location: self.vendor_location&.location, gstin: self.vendor_location&.gstin, address: self.vendor_location&.address },
      department_attributes: { id: self.department_id, name: self.department&.name },
      location_attributes: { id: self.location_id, name: self.location&.name },
      cost_center_attributes: { id: self.cost_center_id, name: self.cost_center&.name }, 
      note: self.note,
      inclusive_of_taxes: !!self.inclusive_of_taxes,
      gst_type_id: self.gst_type_id,
      tax_rate_id: self.tax_rate_id,
      tds_slab_id: self.tds_slab_id,
      original_amount_attributes: {id: self.original_amount_id, value: self.original_amount&.value, currency_id: self.original_amount&.currency_id},
      net_amount_attributes: {id: self.original_amount_id, value: self.original_amount&.value, currency_id: self.original_amount&.currency_id},
      payable_amount_attributes: {id: self.payable_amount_id, value: self.payable_amount&.value, currency_id: self.payable_amount&.currency_id},
      vendor_locations: fetch_vendor_locations.as_json,
      bank_accounts: fetch_vendor_bank_accounts.as_json,
      agreement_type: 'beneficiary',
      vendor_name: self.vendor&.name,
      vendor_id: self.vendor_id,
      creation_date: self.created_at.to_date,
      remaining_amount: (self.balance_due&.value.to_f - self.payments.successful.joins(:amount).sum(:value)),
      status_attributes: {id: self.reload.status&.id, name: self.status&.name, 
      roundoff_amount: self.roundoff_amount,
      net_payable_amount: self.balance_due&.value,
      display_name: self.status&.name&.titleize, payment_agreement_status: self.payment_agreement&.status&.name},
      bank_payment_request_id: (self.payments.first.payment_order.bank_payment_request.id rescue nil)
    }
  end

  def document_owner_id
    'creator_id'
  end

  private

  def fetch_vendor_locations
    self.vendor&.gstin_locations&.as_json
  end

  def fetch_vendor_bank_accounts
    self.vendor&.bank_accounts&.non_deleted&.as_json
  end

  def update_creator_id
    if self.creator_id.blank?
      self.update(creator: RequestStore.store[:current_user])
    end
  end

  def update_company_id
    if self.company_id.blank?
      self.update(company_id: RequestStore.store[:current_user].company_id)
    end
  end

  def update_status
    self.update(status_id: BeneficiaryPaymentStatus.id_for(:unpaid))
  end

  def payment_agreement_related_fields
    if self.payment_agreement.present?
      if self.vendor_id.blank?
        errors.add(:vendor, 'cannot be blank')
      end
      if self.vendor_location_id.blank?
        errors.add(:vendor_location, 'cannot be blank')
      end

      if self.bank_account_id.blank?
        errors.add(:bank_account, 'name cannot be blank')
      end
      if self.cost_center_id.blank?
        errors.add(:cost_center, 'cannot be blank')
      end
      if self.department_id.blank?
        errors.add(:department, 'cannot be blank')
      end
      if self.location_id.blank?
        errors.add(:location, 'cannot be blank')
      end
      # Don't check for id as it is nested attribute
      if self.original_amount.blank?
        errors.add(:original_amount, 'cannot be blank')
      end
      if self.gst_type_id.blank?
        errors.add(:tax_type, 'cannot be blank')
      end
      if self.tax_rate_id.blank?
        errors.add(:tax, 'cannot be blank')
      end
    end
  end
end
