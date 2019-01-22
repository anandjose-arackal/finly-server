class AddPinCodeToAddresses < ActiveRecord::Migration[4.2]
  def change
    add_column :addresses, :pin_code, :string
  end
end
