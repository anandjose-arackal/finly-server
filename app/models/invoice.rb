# == Schema Information
#
# Table name: invoices
#
#  id                 :integer          not null, primary key
#  address_id         :integer
#  date               :date
#  due_date           :date
#  invoice_number     :string(255)
#  SGST               :decimal(64, 12)
#  CGST               :decimal(64, 12)
#  IGST               :decimal(64, 12)
#  tax_type_id        :integer
#  discount           :decimal(64, 12)
#  discount_type_id   :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  gross_amount_id    :integer
#  net_amount_id      :integer
#  inclusive_of_taxes :boolean
#  amount_id          :integer
#  TDS                :decimal(64, 12)
#  tds_type_id        :integer
#  gst_type_id        :integer
#  payment_id         :integer
#

# gst_type_id: 1 - IGST
#              2 - CGST + SGST

class Invoice < ActiveRecord::Base
  belongs_to :address
  belongs_to :amount
  belongs_to :gross_amount, class_name: "Amount"
  belongs_to :net_amount, class_name: "Amount"

  belongs_to :payment

  has_many :invoice_attachments

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :invoice_attachments
  accepts_nested_attributes_for :amount

  validates :gross_amount, presence: true
  validates :net_amount, presence: true
  validates :amount, presence: true
end
