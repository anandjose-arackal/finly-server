class ChangePrecisionOfTaxAndDiscountInPurchaseOrderItem < ActiveRecord::Migration[4.2]
  def change
    change_column :purchase_order_items, :tax, :decimal, precision: 10, scale: 5
    change_column :purchase_order_items, :discount, :decimal, precision: 10, scale: 5
    change_column :purchase_order_items, :tds, :decimal, precision: 10, scale: 5
    change_column :purchase_order_items, :rate, :decimal, precision: 10, scale: 5
  end
end
