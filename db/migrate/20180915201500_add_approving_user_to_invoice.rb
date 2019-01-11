class AddApprovingUserToInvoice < ActiveRecord::Migration[4.2]
  def change
    # Seed status tags for invoice processing
    StatusTag.seed_data

    # Add controlling users to invoices
    add_column :invoices, :controlling_user_id, :integer, references: 'User', foreign_key: true, index: true
    add_column :invoices, :controlling_user_role_id, :integer, references: "UserRole", foreign_key: true, index: true
    add_column :invoices, :controlling_for_user_id, :integer, references: 'User', foreign_key: true, index: true
    add_column :invoices, :controlling_for_user_role_id, :integer, references: "UserRole", foreign_key: true, index: true
  end
end
