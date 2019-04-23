class RemovePoPrevAdjustedAdvanceFromInvoices < ActiveRecord::Migration[5.2]
  def change
  	remove_column :invoices, :po_prev_adjusted_advance, :integer
  end
end
