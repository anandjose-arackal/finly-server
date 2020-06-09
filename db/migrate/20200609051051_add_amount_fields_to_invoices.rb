class AddAmountFieldsToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :gross_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoices, :discount_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoices, :freight_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoices, :taxable_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoices, :tax_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoices, :tds_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoices, :net_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoices, :po_advance_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoices, :advance_paid_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoices, :total_paid_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoices, :balance_due_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoices, :currency_code, :string, index: true

    add_column :invoice_line_items, :gross_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoice_line_items, :discount_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoice_line_items, :taxable_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoice_line_items, :tax_amount, :decimal, precision: 20, scale: 10, index: true
    add_column :invoice_line_items, :net_amount, :decimal, precision: 20, scale: 10, index: true
  end
end
