class AddAuthorizedToVendors < ActiveRecord::Migration[4.2]
  def change
    add_column :yes_bank_vendors, :authorized, :boolean
  end
end
