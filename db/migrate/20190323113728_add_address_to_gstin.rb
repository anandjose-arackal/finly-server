class AddAddressToGstin < ActiveRecord::Migration[5.2]
  def change
    add_column :gstins, :address, :text
  end
end
