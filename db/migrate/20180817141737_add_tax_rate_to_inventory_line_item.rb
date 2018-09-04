class AddTaxRateToInventoryLineItem < ActiveRecord::Migration
  def change
    add_reference :inventory_line_items, :tax_rate, index: true, foreign_key: true
  end
end
