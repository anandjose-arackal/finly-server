# == Schema Information
#
# Table name: purchase_order_items
#
#  id                     :integer          not null, primary key
#  purchase_order_id      :integer
#  inventory_line_item_id :integer
#  product_id             :string(255)
#  description            :string(255)
#  hsn_sac                :string(255)
#  quantity               :integer
#  rate                   :decimal(20, 5)
#  tax                    :decimal(20, 5)
#  tds                    :decimal(20, 5)
#  discount               :decimal(20, 5)
#  tax_amount_id          :integer
#  tds_amount_id          :integer
#  discount_amount_id     :integer
#  total_amount_id        :integer
#  delivery_date          :date
#  comment                :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  delivered              :integer          default(0)
#  accepted               :integer          default(0)
#  rejected               :integer          default(0)
#

class PurchaseOrderItem < ActiveRecord::Base

  validates :inventory_line_item_id, presence: true
  validates :purchase_order_id, presence: true

  belongs_to :purchase_order
  belongs_to :tax_amount, class_name: "Amount"
  belongs_to :discount_amount, class_name: "Amount"
  belongs_to :total_amount, class_name: "Amount"



  accepts_nested_attributes_for :tax_amount, :discount_amount,
                                :total_amount

end