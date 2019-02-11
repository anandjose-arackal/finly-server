class ChangeTypeForDescriptionInYesBankVendor < ActiveRecord::Migration[4.2]
  def change
    change_column :yes_bank_vendors, :description, :text
  end
end
