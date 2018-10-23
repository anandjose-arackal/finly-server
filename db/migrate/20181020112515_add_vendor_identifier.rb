class AddVendorIdentifier < ActiveRecord::Migration
  def change
    Purpose.seed_data
    add_column :yes_bank_vendors, :vendor_id, :string, index: true
  end
end
