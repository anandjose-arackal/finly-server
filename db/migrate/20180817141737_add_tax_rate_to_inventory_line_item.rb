class AddTaxRateToInventoryLineItem < ActiveRecord::Migration[4.2]
  def change
    add_reference :inventory_line_items, :tax_rate, index: true, foreign_key: true
  end
end
