class AddPoPrevAdjustedAdvanceToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :po_prev_adjusted_advance, :integer
  end
end
