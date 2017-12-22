class ChangeTypeForDescriptionInYesBankVendor < ActiveRecord::Migration
  def change
    change_column :yes_bank_vendors, :description, :text
  end
end
