class AddVendorSequenceIdToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :vendor_sequence_id, :string
    add_column :invoices, :vendor_gstin, :string
  end
end
