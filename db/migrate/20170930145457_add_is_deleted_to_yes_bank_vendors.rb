class AddIsDeletedToYesBankVendors < ActiveRecord::Migration[4.2]
  def change
    add_column :yes_bank_vendors, :is_deleted, :boolean, default: false
  end
end
