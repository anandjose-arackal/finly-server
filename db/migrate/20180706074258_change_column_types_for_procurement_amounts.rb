class ChangeColumnTypesForProcurementAmounts < ActiveRecord::Migration[4.2]
  def change
    change_column :purchase_order_items, :rate, :decimal, :precision => 20, :scale => 5
    change_column :purchase_order_items, :tax, :decimal, :precision => 20, :scale => 5
    change_column :purchase_order_items, :tds, :decimal, :precision => 20, :scale => 5
    change_column :purchase_order_items, :discount, :decimal, :precision => 20, :scale => 5


    change_column :document_items, :quantity, :decimal, :precision =>  20, :scale => 5
    change_column :document_items, :rate, :decimal, :precision =>  20, :scale => 5
    change_column :document_items, :tax, :decimal, :precision =>  20, :scale => 5
    change_column :document_items, :tds, :decimal, :precision =>  20, :scale => 5
    change_column :document_items, :discount, :decimal, :precision =>  20, :scale => 5
  end
end
