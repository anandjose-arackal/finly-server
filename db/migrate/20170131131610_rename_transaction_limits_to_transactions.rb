class RenameTransactionLimitsToTransactions < ActiveRecord::Migration[4.2]
  def change
    rename_column :card_limits, :transaction_limit, :transactions
  end
end
