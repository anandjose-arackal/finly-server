class ChangePrecisionOfTaxesAndDiscountsInInvoiceItems < ActiveRecord::Migration[4.2]
  def change
    change_column :invoice_line_items, :rate, :decimal, precision: 20, scale: 10
    change_column :invoice_line_items, :discount, :decimal, precision: 20, scale: 10
    change_column :invoice_line_items, :tax, :decimal, precision: 20, scale: 10
    rename_column :invoice_line_items, :tax_type_id, :gst_type_id
  end
end
