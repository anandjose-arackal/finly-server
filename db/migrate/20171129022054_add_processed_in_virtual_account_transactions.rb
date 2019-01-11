class AddProcessedInVirtualAccountTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :virtual_account_transactions, :processed, :boolean
  end
end
