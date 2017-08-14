class RemoveOpeningAndClosingBalancesFromPayments < ActiveRecord::Migration
  def change
    remove_column :payments, :initiating_account_opening_balance_id, :integer
    remove_column :payments, :initiating_account_closing_balance_id, :integer
    remove_column :payments, :receiving_account_opening_balance_id, :integer
    remove_column :payments, :receiving_account_closing_balance_id, :integer
  end
end
