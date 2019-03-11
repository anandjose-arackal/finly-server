class AddInwardTypeIndexToInvoices < ActiveRecord::Migration[5.2]
  def change
  	add_index :invoices, :invoice_type_id
  end
end
