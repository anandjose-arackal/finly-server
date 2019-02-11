class ChangeInvoiceNumberColumnToText < ActiveRecord::Migration[4.2]
  def change
    change_column :invoices, :invoice_number, :text
  end
end