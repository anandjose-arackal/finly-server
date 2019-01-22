class AddGstTypeIdToOutwardInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :gst_type_id, :integer
  end
end
