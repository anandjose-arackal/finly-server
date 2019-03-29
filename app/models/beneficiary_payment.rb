# == Schema Information
#
# Table name: beneficiary_payments
#
#  id                 :bigint(8)        not null, primary key
#  name               :string(255)
#  vendor_id          :integer
#  bank_account_id    :integer
#  category_id        :integer
#  department_id      :integer
#  original_amount_id :integer
#  tax_amount_id      :integer
#  payable_amount_id  :integer
#  inclusive_of_taxes :boolean
#  gst_type_id        :integer
#  tax                :decimal(10, )
#  tds_slab_id        :integer
#  company_id         :integer
#  sub_department_id  :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  status_id          :integer
#  tds_amount_id      :integer
#  balance_due_id     :integer
#  net_amount_id      :integer
#  gross_amount_id    :integer
#  roundoff_amount    :decimal(10, )
#  cost_center_id     :integer
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
  include MathUtil
  
  belongs_to :vendor,  class_name: 'YesBankVendor'
  belongs_to :bank_account
  belongs_to :category, optional: true
  belongs_to :cost_center, optional: true

  belongs_to :department, optional: true
  belongs_to :sub_department, optional: true, class_name: 'Department', foreign_key: :sub_department_id

  belongs_to :company, optional: true
  belongs_to :gst_type, optional: true
  belongs_to :tds_slab, optional: true, class_name: 'TdsRatesList'

  belongs_to :status, class_name: 'BeneficiaryPaymentStatus'

  belongs_to :original_amount, class_name: "Amount"
  belongs_to :tax_amount, optional: true, class_name: "Amount"
  belongs_to :payable_amount, optional: true, class_name: "Amount"
  belongs_to :balance_due, optional: true, class_name: "Amount"
  belongs_to :tds_amount, optional: true, class_name: "Amount"
  belongs_to :net_amount, optional: true, class_name: "Amount"
  belongs_to :gross_amount, optional: true, class_name: "Amount"

  has_many :payments, as: :parent

  accepts_nested_attributes_for :original_amount
  accepts_nested_attributes_for :tax_amount
  accepts_nested_attributes_for :payable_amount

  # after_commit :calculate_tax_and_amount

  def tax_rate
  	self.tax
  end

  def unpaid?
    return nil if self.status.blank?
    return (self.status_id == BeneficiaryPaymentStatus.id_for(:unpaid))
  end

  def as_json
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
      balance_due: self.balance_due&.value,
      taxable_amount: precision_value(self.gross_amount&.value),
      editable: self.unpaid?,
      tax_rate: precision_value(self.tax_rate),
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
      original_amount: precision_value(self.original_amount&.value)
  	}
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

      # net_amount = gross_amount - tds_amount
      net_amount = self.original_amount.value - tds_amount
    else # calculate proactively
      
      # calculate_exclusive_taxes
      net_amount = TaxCalculationUtils.exclusive_tax_amount(original_amount, (self.tax))
      tax_amount = net_amount - original_amount
      # calculate_tds
      tds = self.tds_slab&.tds
      new_gross_amount = TaxCalculationUtils.tds_amount(original_amount, tds)
      tds_amount = original_amount - new_gross_amount

      net_amount = original_amount + tax_amount - tds_amount
    end


    self.roundoff_amount = self.roundoff_amount.to_f # even if it's nil, it gets converted to 0
    if self.roundoff_amount != 0
      balance_due_amount = precision_value (net_amount + self.roundoff_amount), 0
    else
      balance_due_amount = precision_value net_amount, 0
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

end
