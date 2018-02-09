class AddInvoiceStatusToOutwardInvoice < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :invoice_status_id, :integer, references: "OutwardInvoiceStatus", foreign_key: true, index: true
  end
end
