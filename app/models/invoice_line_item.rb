# == Schema Information
#
# Table name: invoice_line_items
#
#  id                 :integer          not null, primary key
#  invoice_id         :integer
#  name               :string(255)
#  quantity           :integer
#  rate               :decimal(10, )
#  tax                :decimal(10, )
#  discount           :decimal(10, )
#  category_id        :integer
#  tax_type_id        :integer
#  tax_amount_id      :integer
#  discount_amount_id :integer
#  amount_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class InvoiceLineItem < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :category
  belongs_to :amount
  belongs_to :discount_amount, class_name: "Amount"
  belongs_to :tax_amount, class_name: "Amount"

  accepts_nested_attributes_for :discount_amount
  accepts_nested_attributes_for :tax_amount
  accepts_nested_attributes_for :amount
end
