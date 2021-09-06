class AddDatesToTaxRate < ActiveRecord::Migration[6.0]
  def change
    add_column :tax_rates, :start_date, :date, index: true
    add_column :tax_rates, :end_date, :date, index: true
  end
end
