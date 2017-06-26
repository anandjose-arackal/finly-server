class RenameReceiptExtractToExpenseDataExtract < ActiveRecord::Migration
  def change
    rename_table :receipt_extracts, :expense_data_extracts
    remove_foreign_key :expense_data_extracts, :receipt
    remove_index :expense_data_extracts, :receipt_id
    remove_column :expense_data_extracts, :receipt_id
    add_column :expense_data_extracts, :extractable_id, :integer, index: true, null: false
    add_column :expense_data_extracts, :extractable_type, :string, index: true, null: false
  end
end
