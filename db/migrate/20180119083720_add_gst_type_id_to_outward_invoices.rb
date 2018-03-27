class AddGstTypeIdToOutwardInvoices < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :gst_type_id, :integer
  end
end
