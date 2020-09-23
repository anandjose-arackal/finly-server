class AddVendorSequenceIdToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :vendor_sequence_id, :text
  end
end
