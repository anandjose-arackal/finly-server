class AddExpectedTdsToOutwardInvoice < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :tds_slab_id, :integer, forieng_key: true, index: true
  end
end
