class AddInvoiceStatusToInwardInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :invoice_status_id, :integer, references: "InwardInvoiceStatus", foreign_key: true, index: true
  end
end
