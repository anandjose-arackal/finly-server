class AddTradeNameToYesBankVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :yes_bank_vendors, :trade_name, :string
  end
end
