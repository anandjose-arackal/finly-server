class CreateBbpsBillerSubscriptionStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :bbps_biller_subscription_statuses do |t|
      t.string :name, index: true, null: false

      t.timestamps
    end
    BbpsBillerSubscriptionStatus.seed_data
    add_column :bbps_biller_subscriptions, :status_id, :integer,
               references: "bbps_biller_subscription_statuses", index: true, null: false, foreign_key: true
  end
end
