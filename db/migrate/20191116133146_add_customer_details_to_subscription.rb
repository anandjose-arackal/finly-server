class AddCustomerDetailsToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_biller_subscriptions, :customer_name, :string, index: true
    add_column :bbps_biller_subscriptions, :customer_email, :string, index: true
    add_column :bbps_biller_subscriptions, :customer_aadhar_number, :string, index: true
    add_column :bbps_biller_subscriptions, :customer_pan, :string, index: true
  end
end
