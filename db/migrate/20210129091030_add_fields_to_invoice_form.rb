class AddFieldsToInvoiceForm < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :transactions_service_period_form, :timestamp
    add_column :invoices, :transactions_service_period_to, :timestamp
  end
end