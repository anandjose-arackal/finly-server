class AddCreatedByToTaxRate < ActiveRecord::Migration[6.0]
  def change
    add_column :tax_rates, :created_by_id, :integer, references: "User", foreign_key: true, index: true
  end
end
