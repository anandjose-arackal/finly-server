class AddProcurementToFeatureSubscription < ActiveRecord::Migration[4.2]
  def change
    add_column :feature_subscriptions, :procurement, :boolean, default: false
  end
end
