class AddBalancesToPayments < ActiveRecord::Migration[4.2]
  def change
    remove_column :payment_trails, :initiating_account_pre_balance_id, :integer
    remove_column :payment_trails, :initiating_account_post_balance_id, :integer
    remove_column :payment_trails, :receiving_account_pre_balance_id, :integer
    remove_column :payment_trails, :receiving_account_post_balance_id, :integer
    remove_column :payment_trails, :payments_id, :integer

    add_column :payment_trails, :payment_id, :integer, references: "Amount", foreign_key: true
    add_column :payments, :initiating_account_closing_balance_id, :integer, references: "Amount", foreign_key: true
    add_column :payments, :receiving_account_closing_balance_id, :integer, references: "Amount", foreign_key: true
  end
end
