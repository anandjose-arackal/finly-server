class AddDetailsToYesBankVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :yes_bank_vendors, :submitted_at, :datetime
    add_column :yes_bank_vendors, :approved_at, :datetime
  end
end
