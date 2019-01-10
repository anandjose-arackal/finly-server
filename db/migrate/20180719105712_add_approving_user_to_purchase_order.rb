class AddApprovingUserToPurchaseOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :purchase_orders, :controlling_user_id, :integer, references: 'User', foreign_key: true, index: true
    add_column :purchase_orders, :controlling_user_role_id, :integer, references: "UserRole", foreign_key: true, index: true
    add_column :purchase_orders, :controlling_for_user_id, :integer, references: 'User', foreign_key: true, index: true
    add_column :purchase_orders, :controlling_for_user_role_id, :integer, references: "UserRole", foreign_key: true, index: true
  end
end
