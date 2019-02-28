# == Schema Information
#
# Table name: inventory_line_items
#
#  id                  :integer          not null, primary key
#  tax                 :decimal(20, 10)
#  discount            :decimal(20, 10)
#  hsn_sac             :string(255)
#  company_id          :integer
#  sku                 :string(255)
#  rate                :decimal(20, 10)
#  description         :text(65535)
#  category_id         :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  note                :text(65535)
#  tax_rate_id         :integer
#  is_deleted          :boolean          default(FALSE), not null
#  item_code           :string(255)
#  account             :string(255)
#  supply_item_type_id :integer
#  deleted_at          :datetime
#

class InventoryLineItem < ApplicationRecord
  include SoftDeletable
  belongs_to :company, optional: true
  belongs_to :category, optional: true
  belongs_to :tax_rate, optional: true

  belongs_to :supply_item_type, optional: true


  validates :rate, presence: true
  validates :description, presence: true

  scope :with_category_id, -> (id){
    where category_id: id
  }

  scope :search, -> (term) {
    where('description like ? OR sku like ? OR note like ? OR hsn_sac like ?', "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%")
  }

  scope :filter_category_id, -> (category_id) {
    where category_id: category_id
  }

  # Filter though supply item type
  scope :filter_item_type, -> (type_id) {
    if type_id.is_a?(Array)
      if type_id.map(&:to_i).include?(SupplyItemType.id_for(:po_item))
        new_type_id = type_id + [nil]
        where supply_item_type_id: new_type_id
      elsif type_id.map(&:to_i).include?(SupplyItemType.id_for(:non_po_item))
        where supply_item_type_id: type_id
      end
    end
  }

  scope :with_id, -> (id) {
    where id: id
  }

  delegate :po_item?, :non_po_item?, to: :supply_item_type

  after_save :budget_trail_entry

  def as_json
    {
        id: id,
        hsn_sac: hsn_sac,
        category_name: category&.name,
        category_id: category_id,
        rate: rate,
        description: description,
        discount: discount,
        sku: sku,
        tax_amount: self.tax_amount,
        tax_rate_id: tax_rate_id,
        tax: tax,
        account: account,
        item_code: item_code,
        supply_item_type_id: supply_item_type_id,
        item_type: supply_item_type.as_json
    }
  end

  def tax_amount
    self.tax_rate&.rate
  end

  private

  def budget_trail_entry
    purchase_order_items = PurchaseOrderItem.with_inventory_line_item(self.id)
    purchase_order_items.each do |item|
      BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.save_trail(item)
    end
  end
end
