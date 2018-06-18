# == Schema Information
#
# Table name: invoices
#
#  id                     :integer          not null, primary key
#  address_id             :integer
#  date                   :date
#  due_date               :date
#  invoice_number         :text(65535)
#  tax_type_id            :integer
#  discount               :decimal(64, 12)
#  discount_type_id       :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  gross_amount_id        :integer
#  net_amount_id          :integer
#  inclusive_of_taxes     :boolean
#  amount_id              :integer
#  tds                    :decimal(64, 12)
#  tds_type_id            :integer
#  gst_type_id            :integer
#  payment_id             :integer
#  discount_amount_id     :integer
#  tds_amount_id          :integer
#  tax_amount_id          :integer
#  tax                    :decimal(64, 12)
#  category_id            :integer
#  original_amount_id     :integer
#  advance_amount_id      :integer
#  advance_type_id        :integer
#  advance                :decimal(20, 10)
#  freight_amount_id      :integer
#  freight_type_id        :integer
#  freight                :decimal(20, 10)
#  roundoff_amount        :decimal(20, 10)
#  balance_due_id         :integer
#  taxable_amount_id      :integer
#  cost_center_id         :integer
#  tds_slab_id            :integer
#  invoice_status_id      :integer
#  company_id             :integer
#  created_by_user_id     :integer
#  paid_amount_id         :integer
#  vendor_id              :integer
#  receiving_account_id   :integer
#  receiving_account_type :string(255)
#  note                   :text(65535)
#  remaining_amount_id    :integer
#

#  gst_type_id: 1 - IGST
#              2 - CGST + SGST

class Invoice < ActiveRecord::Base
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
  belongs_to :tds_slab, class_name: TdsRatesList

  # because multiple payments can be made against one invoice
  has_many :payments, as: :parent

  has_many :invoice_items, class_name: "InvoiceLineItem", as: :parent
  has_many :invoice_attachments
  has_many :custom_fields, as: :parent, dependent: :destroy

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


  # validates :gross_amount, presence: true
  # validates :net_amount, presence: true
  # validates :amount, presence: true

  scope :with_id, -> (id) {where id: id}
  scope :with_cost_center_id, -> (id) {where cost_center_id: id}

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

  private


end