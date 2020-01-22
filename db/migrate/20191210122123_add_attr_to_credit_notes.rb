class AddAttrToCreditNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_notes, :deleted_at, :datetime, index: true
    add_column :credit_notes, :roundoff_amount_id, :integer, references: 'Amount', index: true, foreign_key: true
    add_column :credit_notes, :department_id, :integer, references: 'Department', index: true, foreign_key: true
    add_column :credit_notes, :cost_center_id, :integer, references: 'CostCenter', index: true, foreign_key: true
  end
end
