class CreateVendorAccounts < ActiveRecord::Migration
  def change
    create_table :vendor_accounts do |t|
      t.references :yes_bank_vendor, index: true, foreign_key: true
      t.string :account_number
      t.string :ifsc
      t.string :name
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :pin_code
      t.string :country

      t.timestamps null: false
    end
  end
end
