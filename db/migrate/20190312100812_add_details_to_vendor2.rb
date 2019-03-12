class AddDetailsToVendor2 < ActiveRecord::Migration[5.2]
  def change
    VendorStatus.seed_data

    add_column :yes_bank_vendors, :status_id, :integer, class_name: "VendorStatus", foreign_key: true, index: true
    add_column :yes_bank_vendors, :policy_id, :integer, class_name: "Policy", foreign_key: true, index: true
    add_column :yes_bank_vendors, :controlling_level_id, :integer, class_name: "ReviewalLevel", foreign_key: true, index: true
  end
end
