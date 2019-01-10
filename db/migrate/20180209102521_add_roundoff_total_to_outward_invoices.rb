class AddRoundoffTotalToOutwardInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :roundoff_total_enabled, :boolean
  end
end
