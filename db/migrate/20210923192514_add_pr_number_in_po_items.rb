class AddPrNumberInPoItems < ActiveRecord::Migration[6.0]
  def change
    add_column :purchase_order_items, :pr_number, :string
  end
end