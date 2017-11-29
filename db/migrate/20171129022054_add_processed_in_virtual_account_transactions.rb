class AddProcessedInVirtualAccountTransactions < ActiveRecord::Migration
  def change
    add_column :virtual_account_transactions, :processed, :boolean
  end
end
