class AddApplicationToPaymentOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_orders, :application, :string
    add_column :payments, :application, :string
  end
end
