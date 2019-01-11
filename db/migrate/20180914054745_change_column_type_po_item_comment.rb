class ChangeColumnTypePoItemComment < ActiveRecord::Migration[4.2]
  def change
    change_column :purchase_order_items, :comment, :text
  end
end
