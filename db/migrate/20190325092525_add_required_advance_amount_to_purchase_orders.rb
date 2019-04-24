class AddRequiredAdvanceAmountToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :requested_advance_amount_id, :integer, references: "Amount", foreign_key: true
  end
end
