class RenameTransactionIdForMappingsTable < ActiveRecord::Migration[4.2]
  def change
    rename_column :invoice_transaction_mappings, :transaction_id, :va_transaction_id
  end
end
