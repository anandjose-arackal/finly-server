class AddTravelRequestsToFeatureSubscription < ActiveRecord::Migration
  def change
    add_column :feature_subscriptions, :travel_request, :boolean, default: false
    add_column :user_panel_subscriptions, :travel_request, :boolean, default: false
  end
end
