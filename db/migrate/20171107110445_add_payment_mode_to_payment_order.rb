class AddPaymentModeToPaymentOrder < ActiveRecord::Migration
  def change
    add_column :payment_orders, :payment_mode, :string
  end
end
