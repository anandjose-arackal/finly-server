class AddNoteDatetimeToReceiptExtracts < ActiveRecord::Migration
  def change
    add_column :expense_data_extracts, :note, :text
    add_column :expense_data_extracts, :datetime, :datetime
    remove_column :expense_data_extracts, :date
    remove_column :expense_data_extracts, :time
    ExpenseDataExtractSource.seed_data
  end
end
