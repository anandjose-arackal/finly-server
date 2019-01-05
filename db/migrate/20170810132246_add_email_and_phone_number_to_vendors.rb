class AddEmailAndPhoneNumberToVendors < ActiveRecord::Migration[4.2]
  def change
    add_column :yes_bank_vendors, :email, :string
    add_column :yes_bank_vendors, :mobile_number, :string
  end
end
