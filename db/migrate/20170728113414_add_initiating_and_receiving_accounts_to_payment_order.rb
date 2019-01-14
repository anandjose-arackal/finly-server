class AddInitiatingAndReceivingAccountsToPaymentOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_orders, :initiating_account_type, :string
    add_column :payment_orders, :receiving_account_type, :string
  end
end
