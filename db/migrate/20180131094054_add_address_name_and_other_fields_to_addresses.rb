class AddAddressNameAndOtherFieldsToAddresses < ActiveRecord::Migration[4.2]
  def change
    add_column :addresses, :address_name, :string
    add_column :addresses, :landmark, :text
  end
end