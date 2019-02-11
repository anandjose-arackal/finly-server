class ChangePrecisionScaleForRatesInInventoryItems < ActiveRecord::Migration[4.2]
  def change
    change_column :inventory_line_items, :rate, :decimal, precision: 20, scale: 10
    change_column :inventory_line_items, :tax, :decimal, precision: 20, scale: 10
    change_column :inventory_line_items, :discount, :decimal, precision: 20, scale: 10
  end
end
