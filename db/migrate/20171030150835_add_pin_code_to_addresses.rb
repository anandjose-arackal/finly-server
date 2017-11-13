class AddPinCodeToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :pin_code, :string
  end
end
