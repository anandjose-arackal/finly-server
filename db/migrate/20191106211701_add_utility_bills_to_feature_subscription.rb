class AddUtilityBillsToFeatureSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :feature_subscriptions, :utility_bills_enabled, :boolean, default: false, index: true
    add_column :bbps_bills, :note, :text
  end
end
