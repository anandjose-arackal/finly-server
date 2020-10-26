class AddBankCodeToVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :yes_bank_vendors, :bank_code, :string
    add_column :yes_bank_vendors, :tax_rate_id, :integer, references: 'TaxRate', foreign_key: true, index: true
  end
end
