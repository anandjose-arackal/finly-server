class AddPoAdvanceAttributeToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :po_advance, :integer
  end
end
