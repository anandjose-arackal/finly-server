# == Schema Information
#
# Table name: invoices
#
#  id                 :integer          not null, primary key
#  address_id         :integer
#  date               :date
#  due_date           :date
#  invoice_number     :string(255)
#  tax_type_id        :integer
#  discount           :decimal(64, 12)
#  discount_type_id   :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  gross_amount_id    :integer
#  net_amount_id      :integer
#  inclusive_of_taxes :boolean
#  amount_id          :integer
#  tds                :decimal(64, 12)
#  tds_type_id        :integer
#  gst_type_id        :integer
#  payment_id         :integer
#  discount_amount_id :integer
#  sgst_amount_id     :integer
#  csgt_amount_id     :integer
#  igst_amount_id     :integer
#  tds_amount_id      :integer
#  tax_amount_id      :integer
#  tax                :decimal(64, 12)
#  category_id        :integer
#  original_amount_id :integer
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

  belongs_to :payment

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
  accepts_nested_attributes_for :custom_fields

  delegate :tax_amount_value, to: :tax_amount
  delegate :tds_amount_value, to: :tax_amount
  delegate :discount_amount_value, to: :discount_amount
  delegate :net_amount_value, to: :net_amount
  delegate :gross_amount_value, to: :gross_amount


  # validates :gross_amount, presence: true
  # validates :net_amount, presence: true
  # validates :amount, presence: true

  def policy
    self.payment&.payment_order&.bank_payment_request&.policy
  end

  # the 'user' will default to the initiating user of the payment
  def user
    self.payment.initiating_user
  end

  private

  def tax_rate_validation

  end

  def tds_rate_validation

  end

end
