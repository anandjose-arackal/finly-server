class AddPolicyToPurchaseOrders < ActiveRecord::Migration
  def change
    add_reference :purchase_orders, :policy, index: true, foreign_key: true
  end
end
