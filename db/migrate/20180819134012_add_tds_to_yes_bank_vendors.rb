class AddTdsToYesBankVendors < ActiveRecord::Migration
  def change
    add_reference :yes_bank_vendors, :tds_rates_list, index: true, foreign_key: true
  end
end
