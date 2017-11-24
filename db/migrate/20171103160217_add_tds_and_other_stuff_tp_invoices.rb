class AddTdsAndOtherStuffTpInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :TDS, :decimal, precision: 64, scale: 12
    add_column :invoices, :tds_type_id, :integer
    add_column :invoices, :gst_type_id, :integer
  end
end
