class ChangeAttributesBbpsBillerSubscriptions < ActiveRecord::Migration[5.2]
  def change
    remove_column :bbps_biller_subscriptions, :customer_params
    add_column :bbps_biller_subscriptions, :label_1, :string
    add_column :bbps_biller_subscriptions, :value_1, :string, index: true
    add_column :bbps_biller_subscriptions, :label_2, :string
    add_column :bbps_biller_subscriptions, :value_2, :string, index: true
    add_column :bbps_biller_subscriptions, :label_3, :string
    add_column :bbps_biller_subscriptions, :value_3, :string, index: true
    add_column :bbps_biller_subscriptions, :label_4, :string
    add_column :bbps_biller_subscriptions, :value_4, :string, index: true
    add_column :bbps_biller_subscriptions, :label_5, :string
    add_column :bbps_biller_subscriptions, :value_5, :string, index: true

    remove_column :bbps_biller_subscriptions, :created_by_user_id, :integer, references: 'users', foreign_key: true, index: true

    add_column :bbps_biller_subscriptions, :user_id, :integer, references: 'User', foreign_key: true, index: true
  end
end
