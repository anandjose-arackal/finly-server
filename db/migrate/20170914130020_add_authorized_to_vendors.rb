class AddAuthorizedToVendors < ActiveRecord::Migration
  def change
    add_column :yes_bank_vendors, :authorized, :boolean
  end
end
