class AddPayableToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :payable, :boolean, default: false
    add_index :invoices, :payable
  end
end
