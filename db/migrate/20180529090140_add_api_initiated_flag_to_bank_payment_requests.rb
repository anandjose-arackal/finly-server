class AddApiInitiatedFlagToBankPaymentRequests < ActiveRecord::Migration
  def change
    add_column :bank_payment_requests, :api_initiated, :boolean, default: false
    add_column :payment_orders, :api_initiated, :boolean, default: false
    add_column :payments, :api_initiated, :boolean, default: false
  end
end
