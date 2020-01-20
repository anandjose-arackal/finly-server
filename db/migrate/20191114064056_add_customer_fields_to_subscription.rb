class AddCustomerFieldsToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_biller_subscriptions, :customer_param_key_1, :string
    add_column :bbps_biller_subscriptions, :customer_param_value_1, :string, index: true

    add_column :bbps_biller_subscriptions, :customer_param_key_2, :string
    add_column :bbps_biller_subscriptions, :customer_param_value_2, :string, index: true

    add_column :bbps_biller_subscriptions, :customer_param_key_3, :string
    add_column :bbps_biller_subscriptions, :customer_param_value_3, :string, index: true

    add_column :bbps_biller_subscriptions, :customer_param_key_4, :string
    add_column :bbps_biller_subscriptions, :customer_param_value_4, :string, index: true

    add_column :bbps_biller_subscriptions, :customer_param_key_5, :string
    add_column :bbps_biller_subscriptions, :customer_param_value_5, :string, index: true
  end
end
