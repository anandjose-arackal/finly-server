class AddPaymentModeToPaymentOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_orders, :payment_mode, :string
  end
end
