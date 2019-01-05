class AddDetailsToVendor < ActiveRecord::Migration[4.2]
  def change
    add_column :yes_bank_vendors, :address, :string
    add_column :yes_bank_vendors, :business_name, :string
    add_reference :yes_bank_vendors, :payment_term
    add_reference :yes_bank_vendors, :currency
  end
end
