class RenameTransactionLimitsToTransactions < ActiveRecord::Migration
  def change
    rename_column :card_limits, :transaction_limit, :transactions
  end
end
