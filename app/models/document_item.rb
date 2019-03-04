# == Schema Information
#
# Table name: document_items
#
#  id                     :integer          not null, primary key
#  parent_document_id     :integer          not null
#  parent_document_type   :string(255)      not null
#  inventory_line_item_id :integer
#  description            :string(255)
#  hsn_sac                :string(255)
#  quantity               :decimal(20, 5)
#  rate                   :decimal(20, 5)
#  tax                    :decimal(20, 5)   default(0.0)
#  tds                    :decimal(20, 5)   default(0.0)
#  discount               :decimal(20, 5)   default(0.0)
#  tax_amount_id          :integer
#  tds_amount_id          :integer
#  discount_amount_id     :integer
#  total_amount_id        :integer
#  delivery_date          :date
#  comment                :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  purchase_order_item_id :integer
#  product_id             :string(255)
#

class DocumentItem < ApplicationRecord
  belongs_to :inventory_line_item, optional: true, class_name: 'Item'
  belongs_to :parent_document, optional: true, polymorphic: true

  belongs_to :tax_amount, optional: true, class_name: 'Amount'
  belongs_to :tds_amount, optional: true, class_name: 'Amount'
  belongs_to :discount_amount, optional: true, class_name: 'Amount'
  belongs_to :total_amount, optional: true, class_name: 'Amount'

  accepts_nested_attributes_for :tax_amount, :tds_amount, :discount_amount,
                                :total_amount
end
