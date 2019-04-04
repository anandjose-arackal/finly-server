class AddOnHoldToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :on_hold, :boolean
    add_column :payments, :disabled, :boolean
  end
end
