class AddDetailsSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_biller_subscriptions, :submitted_at, :datetime
    add_column :bbps_biller_subscriptions, :approved_at, :datetime
    add_column :bbps_bills, :submitted_at, :datetime
    add_column :bbps_bills, :approved_at, :datetime
  end
end
