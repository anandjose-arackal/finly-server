# == Schema Information
#
# Table name: inventory_line_items
#
#  id                     :integer          not null, primary key
#  tax                    :decimal(20, 10)
#  discount               :decimal(20, 10)
#  hsn_sac                :string(255)
#  company_id             :integer
#  sku                    :string(255)
#  rate                   :decimal(20, 10)
#  description            :text(65535)
#  category_id            :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  note                   :text(65535)
#  tax_rate_id            :integer
#  is_deleted             :boolean          default(FALSE), not null
#  item_code              :string(255)
#  account                :string(255)
#  supply_item_type_id_id :integer
#  supply_item_type_id    :integer
#

class InventoryLineItem < ActiveRecord::Base
  include SoftDeletable
  belongs_to :company
  belongs_to :category
  belongs_to :tax_rate

  belongs_to :supply_item_type


  validates :rate, presence: true
  validates :description, presence: true

  scope :search, -> (term) {
    where('description like ? OR sku like ? OR note like ? OR hsn_sac like ?', "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%")
  }

  scope :filter_category_id, -> (category_id) {
    where category_id: category_id
  }

  # Filter though supply item type
  scope :filter_item_type, -> (type_id) {
    where supply_item_type_id: type_id
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
        supply_item_type_id: supply_item_type_id
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
