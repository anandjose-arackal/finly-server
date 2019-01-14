class CreateExpenseDataExtractStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :expense_data_extract_statuses do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_column :expense_data_extracts, :status_id, :integer, references: 'ExpenseDataExtractStatus', index: true, foreign_key: true, null: false
    remove_column :expense_data_extracts, :illegible
    ExpenseDataExtractStatus.seed_data
    ExpenseDataExtract.update_all(status_id: ExpenseDataExtractStatus.id_for(:success))
  end
end
