class AddProcurementToFeatureSubscription < ActiveRecord::Migration
  def change
    add_column :feature_subscriptions, :procurement, :boolean, default: false
  end
end
