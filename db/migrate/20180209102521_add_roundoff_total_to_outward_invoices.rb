class AddRoundoffTotalToOutwardInvoices < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :roundoff_total_enabled, :boolean
  end
end
