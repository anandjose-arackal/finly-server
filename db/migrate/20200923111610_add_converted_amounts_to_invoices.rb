class AddConvertedAmountsToInvoices < ActiveRecord::Migration[5.2]
  def change
    # Invoice
    # add_column :invoices, :reporting_currency, :string
    # add_column :invoices, :conversion_date, :date
    # add_column :invoices, :conversion_rate, :decimal, :precision => 10, :scale => 5
    # add_column :invoices, :retrieve_conversion_rate, :boolean, default: true

    # add_column :invoices, :invoice_taxable_amount, :decimal, :precision => 20, :scale => 5
    # add_column :invoices, :invoice_freight_amount, :decimal, :precision => 20, :scale => 5
    # rename_column :invoices, :sub_total_amount, :invoice_sub_total_amount
    # rename_column :invoices, :total_amount, :invoice_total_amount
    # rename_column :invoices, :payment_outside_finly_amount, :invoice_paid_outside_amount
    add_column :invoices, :invoice_roundoff_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_balance_due, :decimal, :precision => 20, :scale => 5

    add_column :invoices, :invoice_gross_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_discount_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_taxable_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_tax_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_tds_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_freight_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_sub_total_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_roundoff_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_advance_paid_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_advance_paid_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_total_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_net_total_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_net_total_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_paid_outside_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_balance_due_converted, :decimal, :precision => 20, :scale => 5

    # Invoice Item
    add_column :invoice_line_items, :item_gross_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoice_line_items, :item_gross_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoice_line_items, :item_discount_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoice_line_items, :item_taxable_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoice_line_items, :item_tax_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoice_line_items, :item_tds_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoice_line_items, :item_net_amount_converted, :decimal, :precision => 20, :scale => 5
    add_column :invoice_line_items, :item_billable_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoice_line_items, :item_billable_amount_converted, :decimal, :precision => 20, :scale => 5
  end
end
