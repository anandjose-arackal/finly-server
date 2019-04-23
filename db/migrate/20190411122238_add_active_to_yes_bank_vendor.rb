class AddActiveToYesBankVendor < ActiveRecord::Migration[5.2]
  def change
    add_column :yes_bank_vendors, :active, :boolean, default: true
  end
end
