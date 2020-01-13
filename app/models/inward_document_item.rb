# == Schema Information
#
# Table name: inward_document_items
#
#  id                       :integer          not null, primary key
#  purchase_order_item_id   :integer
#  inward_document_id       :integer
#  inventory_line_item_id   :integer
#  product_id               :string(255)
#  description              :text(65535)
#  quantity                 :decimal(20, 5)
#  delivered                :decimal(20, 5)
#  accepted                 :decimal(20, 5)
#  rejected                 :decimal(20, 5)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  comment                  :string(255)
#  previously_delivered     :decimal(20, 5)
#  is_deleted               :boolean          default(FALSE), not null
#  deleted_at               :datetime
#  accepting_item_amount_id :integer
#  billable_amount          :decimal(20, 5)   default(0.0)
#  order_amount             :decimal(20, 5)   default(0.0)
#  previously_billed_amount :decimal(20, 5)   default(0.0)
#  product_type_id          :integer          default(1)
#

class InwardDocumentItem < ApplicationRecord
  include SoftDeletable
  belongs_to :inward_document, optional: true
  belongs_to :inventory_line_item, optional: true, class_name: 'Item'
  belongs_to :product_type, optional: true
  belongs_to :purchase_order_item, optional: true
  belongs_to :accepting_item_amount, optional: true, class_name: "Amount"


  def per_unit_price
    price= self.purchase_order_item&.taxable_amount&.value/self.purchase_order_item.quantity rescue nil
    price.round(2) if price.present?
  end
end
