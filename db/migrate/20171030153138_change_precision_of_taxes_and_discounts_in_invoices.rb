class ChangePrecisionOfTaxesAndDiscountsInInvoices < ActiveRecord::Migration
  def change
    change_column :invoices, :discount, :decimal, precision: 64, scale: 12
    change_column :invoices, :SGST, :decimal, precision: 64, scale: 12
    change_column :invoices, :CGST, :decimal, precision: 64, scale: 12
    change_column :invoices, :IGST, :decimal, precision: 64, scale: 12
  end
end
