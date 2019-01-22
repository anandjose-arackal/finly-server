class CreateVendorAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :vendor_accounts do |t|
      t.integer :balance_id, references: "Amount", foreign_key: true, index: true
      t.integer :vendor_id, references: "YesBankVendor", foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
