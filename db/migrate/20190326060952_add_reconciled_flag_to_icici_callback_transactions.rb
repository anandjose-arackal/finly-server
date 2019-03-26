class AddReconciledFlagToIciciCallbackTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :icici_transaction_callbacks, :reconciled, :boolean, default: false
  end
end
