class AddTaxInsteadOfIndividuallyStoringGst < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :tax_rate, :decimal, precision: 64, scale: 12
    remove_column :invoices, :SGST, :decimal, precision: 64, scale: 12
    remove_column :invoices, :IGST, :decimal, precision: 64, scale: 12
    remove_column :invoices, :CGST, :decimal, precision: 64, scale: 12
  end
end