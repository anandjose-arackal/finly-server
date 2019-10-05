class AddTaxRateToExpenses < ActiveRecord::Migration[5.2]
  def change
    add_column :expenses, :tax_rate_id, :integer, references: "TaxRate", foreign_key: true, index: true
  end
end
