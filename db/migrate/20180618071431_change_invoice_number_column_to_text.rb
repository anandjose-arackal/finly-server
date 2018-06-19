class ChangeInvoiceNumberColumnToText < ActiveRecord::Migration
  def change
    change_column :invoices, :invoice_number, :text
  end
end