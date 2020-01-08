class CreateBbpsSubscriptionFields < ActiveRecord::Migration[5.2]
  def change
    create_table :bbps_subscription_fields do |t|
      t.string :label, index: true
      t.string :value, index: true

      t.integer :subscription_id, references: 'BbpsBillerSubscription', index: true, foreign_key: true
      t.timestamps
    end

    remove_column :bbps_biller_subscriptions, :label_1, :string
    remove_column :bbps_biller_subscriptions, :value_1, :string, index: true
    remove_column :bbps_biller_subscriptions, :label_2, :string
    remove_column :bbps_biller_subscriptions, :value_2, :string, index: true
    remove_column :bbps_biller_subscriptions, :label_3, :string
    remove_column :bbps_biller_subscriptions, :value_3, :string, index: true
    remove_column :bbps_biller_subscriptions, :label_4, :string
    remove_column :bbps_biller_subscriptions, :value_4, :string, index: true
    remove_column :bbps_biller_subscriptions, :label_5, :string
    remove_column :bbps_biller_subscriptions, :value_5, :string, index: true
  end
end
