class RenameStateCodeInVendor < ActiveRecord::Migration[4.2]
  def change
    rename_column :yes_bank_vendors, :state_code, :state_code_id
    change_column :yes_bank_vendors, :state_code_id, :integer, foreign_key: true, index: true
  end
end
