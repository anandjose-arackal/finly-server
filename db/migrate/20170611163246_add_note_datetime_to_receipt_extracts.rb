class AddNoteDatetimeToReceiptExtracts < ActiveRecord::Migration
  def change
    # add_column :expense_data_extracts, :note, :text
    # add_column :expense_data_extracts, :datetime, :datetime
    # remove_column :expense_data_extracts, :date
    remove_foreign_key :expense_data_extracts, :receipt_extract_source_id
    remove_index :expense_data_extracts, :receipt_extract_source_id
    remove_column :expense_data_extracts, :receipt_extract_source_id
    add_column :expense_data_extracts, :expense_data_extract_source_id, :integer, references: 'ExpenseDataExtractSource', index: true, foreign_key: true, null: false
    # rename_column :expense_data_extracts, :receipt_extract_source_id, :expense_data_extract_source_id
    ExpenseDataExtractSource.seed_data
  end
end
