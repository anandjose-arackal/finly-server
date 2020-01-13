class ChangeDatatypeOfPoAdvanceInInvoices < ActiveRecord::Migration[5.2]
  def change
  	change_column :invoices, :po_advance, :decimal, precision: 20, scale: 2
  	change_column :invoices, :po_prev_adjusted_advance, :decimal, precision: 20, scale: 2
  end
end
