class AddInitiatingAndReceivingAccountsToPaymentOrder < ActiveRecord::Migration
  def change
    add_column :payment_orders, :initiating_account_type, :string
    add_column :payment_orders, :receiving_account_type, :string
  end
end
