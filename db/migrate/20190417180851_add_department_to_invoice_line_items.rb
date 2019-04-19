class AddDepartmentToInvoiceLineItems < ActiveRecord::Migration[5.2]
  def change
    add_column :invoice_line_items, :department_id, :integer, references: 'Department', foreign_key: true
    add_index :invoice_line_items, :department_id
  end
end
