class ChangeTaxRatesModelToHaveNewAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :tax_rates, :cgst, :decimal, precision: 10, scale: 5
    add_column :tax_rates, :sgst, :decimal, precision: 10, scale: 5
    add_column :tax_rates, :igst, :decimal, precision: 10, scale: 5
  end
end
