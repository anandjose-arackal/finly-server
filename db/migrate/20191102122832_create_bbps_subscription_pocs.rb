class CreateBbpsSubscriptionPocs < ActiveRecord::Migration[5.2]
  def change
    create_table :bbps_subscription_pocs do |t|
      t.integer :user_id, references: 'User', foreign_key: true, index: true
      t.integer :subscription_id, references: 'BbpsBillerSubscription', foreign_key: true, index: true
      t.timestamps
    end
  end
end
