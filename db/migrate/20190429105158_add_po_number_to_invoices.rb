class AddPoNumberToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :po_number, :string
    add_index :invoices, :po_number
  end
end
