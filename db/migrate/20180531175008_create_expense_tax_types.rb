class CreateExpenseTaxTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :expense_tax_types do |t|
      t.string :name, null: false, index: true

      t.timestamps null: false
    end
    ExpenseTaxType.seed_data
    add_reference :expenses, :expense_tax_type, index: true, foreign_key: true
    add_column :expenses, :gst_percentage, :decimal
    add_column :expenses, :tds_percentage, :decimal
    add_column :expenses, :reimbursable_amount_id, :integer, references: 'Amount', index: true, foreign_key: true
  end
end
