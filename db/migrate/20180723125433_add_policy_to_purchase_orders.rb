class AddPolicyToPurchaseOrders < ActiveRecord::Migration
  def change
    add_reference :purchase_orders, :policy, index: true, foreign_key: true
    add_column :purchase_orders, :controlling_level_id, :integer, references: 'ReviewalLevel', index: true, foreign_key: true
  end
end
