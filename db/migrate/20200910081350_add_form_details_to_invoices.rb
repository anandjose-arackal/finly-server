class AddFormDetailsToInvoices < ActiveRecord::Migration[5.2]
  def change
    # add_column :invoices, :vendor_sequence_id, :string
    # add_column :invoices, :vendor_trade_name, :string
    # add_column :invoices, :vendor_gstin, :string
    # add_column :invoices, :vendor_pan, :string
    add_column :invoices, :vendor_bank_account_number, :string
    add_column :invoices, :vendor_bank_account_ifsc, :string

    add_column :invoices, :invoice_gross_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_discount_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_tax_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :invoice_tds_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :payment_outside_finly_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :sub_total_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoices, :total_amount, :decimal, :precision => 20, :scale => 5

    add_column :invoices, :base_currency, :string

    # Invoice Items
    add_column :invoice_line_items, :item_tds_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoice_line_items, :item_net_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoice_line_items, :item_tax_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoice_line_items, :item_taxable_amount, :decimal, :precision => 20, :scale => 5
    add_column :invoice_line_items, :item_discount_amount, :decimal, :precision => 20, :scale => 5
  end
end
