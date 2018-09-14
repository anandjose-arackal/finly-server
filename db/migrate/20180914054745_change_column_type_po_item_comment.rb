class ChangeColumnTypePoItemComment < ActiveRecord::Migration
  def change
    change_column :purchase_order_items, :comment, :text
  end
end
