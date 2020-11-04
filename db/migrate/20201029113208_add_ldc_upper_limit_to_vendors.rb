class AddLdcUpperLimitToVendors < ActiveRecord::Migration[6.0]
  def change
    add_column :yes_bank_vendors, :ldc_upper_limit_amount, :decimal, :precision => 20, :scale => 5
    remove_column :yes_bank_vendors, :ldc_upper_limit_id, :integer
  end
end
