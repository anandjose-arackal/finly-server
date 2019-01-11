class AddExpectedTdsToOutwardInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :tds_slab_id, :integer, references: "TdsRatesList", foreign_key: true, index: true
  end
end