class RenameReceiptExtractSourceToExpenseDataExtractSource < ActiveRecord::Migration
  def change
    rename_table :receipt_extract_sources, :expense_data_extract_sources
    ExpenseDataExtractSource.seed_data
  end
end
