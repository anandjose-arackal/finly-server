class AddTdsToYesBankVendors < ActiveRecord::Migration[4.2]
  def change
    add_reference :yes_bank_vendors, :tds_rates_list, index: true, foreign_key: true
  end
end
