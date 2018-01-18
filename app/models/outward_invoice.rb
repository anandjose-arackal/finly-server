# == Schema Information
#
# Table name: outward_invoices
#
#  id                  :integer          not null, primary key
#  customer_id         :integer
#  invoice_date        :date
#  invoice_due_date    :date
#  amount_id           :integer
#  discount            :decimal(10, 5)
#  tax                 :decimal(10, 5)
#  discount_amount_id  :integer
#  tax_amount_id       :integer
#  original_amount_id  :integer
#  paid_amount_id      :integer
#  advance             :decimal(10, 5)
#  freight_amount_id   :integer
#  tds_amount_id       :integer
#  category_id         :integer
#  balance_due_id      :integer
#  roundoff_amount     :decimal(10, 5)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  gross_amount_id     :integer
#  policy_id           :integer
#  billing_address_id  :integer
#  shipping_address_id :integer
#  invoice_status_id   :integer
#  company_id          :integer
#

class OutwardInvoice < ActiveRecord::Base
  belongs_to :customer
  belongs_to :company
  belongs_to :amount
  belongs_to :discount_amount, class_name: "Amount"
  belongs_to :tax_amount, class_name: "Amount"
  belongs_to :original_amount, class_name: "Amount"
  belongs_to :paid_amount, class_name: "Amount"
  belongs_to :balance_due, class_name: "Amount"
  belongs_to :freight_amount, class_name: "Amount"
  belongs_to :advance_amount, class_name: "Amount"
  belongs_to :net_amount, class_name: "Amount"
  belongs_to :gross_amount, class_name: "Amount"
  belongs_to :invoice_status, class_name: "OutwardInvoiceStatus"
  belongs_to :payment_term
  belongs_to :shipping_address, class_name: "Address"
  belongs_to :billing_address, class_name: "Address"

  has_many :invoice_items, class_name: "InvoiceLineItem", as: :parent
  has_many :payments, as: :parent

  delegate :unpaid?, :partially_paid?, :closed?, :incomplete?, to: :invoice_status

  accepts_nested_attributes_for :customer
  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :gross_amount
  accepts_nested_attributes_for :net_amount
  accepts_nested_attributes_for :discount_amount
  accepts_nested_attributes_for :tax_amount
  accepts_nested_attributes_for :original_amount
  accepts_nested_attributes_for :freight_amount
  # accepts_nested_attributes_for :custom_fields
  accepts_nested_attributes_for :advance_amount
  accepts_nested_attributes_for :balance_due
  accepts_nested_attributes_for :invoice_items, allow_destroy: true

  validates :invoice_status, presence: true

  # todo - add validations for the particular invoice when it moves to unpaid state
  validates :invoice_items, presence: true, if: :invoice_saved?

  def invoice_status_identifier
    self.invoice_status&.name
  end

  private

  def invoice_saved?

  end

end
