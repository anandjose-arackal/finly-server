class AddTdsSlabIdToInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :tds_slab_id, :integer, references: "TdsRateList", foreign_key: true, index: true
  end
end
