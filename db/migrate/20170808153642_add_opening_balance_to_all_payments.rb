class AddOpeningBalanceToAllPayments < ActiveRecord::Migration
  def change
    add_column :payments, :initiating_account_opening_balance_id, :integer
    add_column :payments, :receiving_account_opening_balance_id, :integer
  end
end
