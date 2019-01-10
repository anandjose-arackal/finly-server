class AddTravelRequestsToFeatureSubscription < ActiveRecord::Migration[4.2]
  def change
    add_column :feature_subscriptions, :travel_request, :boolean, default: false
    add_column :user_panel_subscriptions, :travel_request, :boolean, default: false
  end
end
