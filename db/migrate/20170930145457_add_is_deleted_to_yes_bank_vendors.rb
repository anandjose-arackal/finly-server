class AddIsDeletedToYesBankVendors < ActiveRecord::Migration
  def change
    add_column :yes_bank_vendors, :is_deleted, :boolean, default: false
  end
end
