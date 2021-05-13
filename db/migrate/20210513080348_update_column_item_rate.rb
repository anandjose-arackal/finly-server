class UpdateColumnItemRate < ActiveRecord::Migration[6.0]
  def change
    ActiveRecord::Migration.change_column :invoice_line_items, :item_rate, :decimal, precision: 20, scale: 5, default: 0
  end
end
