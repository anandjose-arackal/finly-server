# == Schema Information
#
# Table name: invoice_line_items
#
#  id                     :integer          not null, primary key
#  invoice_id             :integer
#  description            :string(255)
#  quantity               :integer
#  rate                   :decimal(20, 10)
#  tax                    :decimal(20, 10)
#  discount               :decimal(20, 10)
#  category_id            :integer
#  gst_type_id            :integer
#  tax_amount_id          :integer
#  discount_amount_id     :integer
#  amount_id              :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  net_amount_id          :integer
#  hsn_sac                :string(255)
#  taxable_amount_id      :integer
#  parent_type            :string(255)
#  parent_id              :string(255)
#  inventory_line_item_id :integer
#

class InvoiceLineItem < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :category
  belongs_to :amount
  belongs_to :discount_amount, class_name: "Amount"
  belongs_to :tax_amount, class_name: "Amount"
  belongs_to :net_amount, class_name: "Amount"
  belongs_to :parent, polymorphic: true
  belongs_to :taxable_amount, class_name: "Amount"

  accepts_nested_attributes_for :discount_amount
  accepts_nested_attributes_for :tax_amount
  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :net_amount

  validates :description, presence: true
  validates :quantity, presence: true
  validates :rate, presence: true
end
