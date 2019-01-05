class AddVendorIdentifier < ActiveRecord::Migration[4.2]
  def change
    Purpose.seed_data
    add_column :yes_bank_vendors, :vendor_id, :string, index: true
  end
end
