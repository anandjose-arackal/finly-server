class AddAdvanceAmountRequiredToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :advance_amount_required, :boolean, default: false
  end
end
