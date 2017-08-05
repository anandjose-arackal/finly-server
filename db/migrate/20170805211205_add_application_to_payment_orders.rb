class AddApplicationToPaymentOrders < ActiveRecord::Migration
  def change
    # add_column :payment_orders, :application, :string
    add_column :payments, :application, :string
  end
end
