class AddOpeningBalanceToAllPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :initiating_account_opening_balance_id, :integer
    add_column :payments, :receiving_account_opening_balance_id, :integer
  end
end
