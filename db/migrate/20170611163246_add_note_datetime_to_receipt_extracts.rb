class AddNoteDatetimeToReceiptExtracts < ActiveRecord::Migration
  def change
    add_column :expense_data_extracts, :note, :text
    add_column :expense_data_extracts, :datetime, :datetime
    remove_column :expense_data_extracts, :date
    rename_column :expense_data_extracts, :receipt_extract_source_id, :expense_data_extract_source_id
    ExpenseDataExtractSource.seed_data
  end
end
