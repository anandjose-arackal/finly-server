class AddTaxableAmountIdToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :taxable_amount_id, :integer
  end
end
