class AddCategoriesAndCostCentersToPurchaseOrderItems < ActiveRecord::Migration[4.2]
  def change
    add_column :purchase_order_items, :category_id, :integer, references: "Category", foreign_ley: true, index: true
    add_column :purchase_order_items, :cost_center_id, :integer, references: "CostCenter", foreign_ley: true, index: true
  end
end
