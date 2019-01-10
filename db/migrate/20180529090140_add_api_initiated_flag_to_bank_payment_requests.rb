class AddApiInitiatedFlagToBankPaymentRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_payment_requests, :api_initiated, :boolean, default: false
    add_column :payment_orders, :api_initiated, :boolean, default: false
    add_column :payments, :api_initiated, :boolean, default: false
  end
end
