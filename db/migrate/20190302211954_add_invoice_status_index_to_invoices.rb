class AddInvoiceStatusIndexToInvoices < ActiveRecord::Migration[5.2]
  def change
  	add_index :invoices, :invoice_status_id
  end
end
