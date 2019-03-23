class RemovePoAdvanceFromInvoices < ActiveRecord::Migration[5.2]
  def change
  	remove_column :invoices, :po_advance, :integer
  end
end
