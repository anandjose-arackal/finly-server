class AddColumnVendorCodeToYesBankVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :yes_bank_vendors, :vedor_code, :string
  end
end
