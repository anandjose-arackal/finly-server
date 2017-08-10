class AddEmailAndPhoneNumberToVendors < ActiveRecord::Migration
  def change
    add_column :yes_bank_vendors, :email, :string
    add_column :yes_bank_vendors, :mobile_number, :string
  end
end
