class AddDiscountTypeIdToPurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :discount_type_id, :integer
  end
end
