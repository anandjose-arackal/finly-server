class AddAdvanceTdsAmountToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :advance_tds_amount_id, :integer, references: 'Amount', foreign_key: true
  end
end
