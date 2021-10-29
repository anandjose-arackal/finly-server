class AddDefaultSubscriptionTypeIdToUserPanelSubscription < ActiveRecord::Migration[6.0]
  def change
    add_reference :user_panel_subscriptions, :default_subscription_type, foreign_key: { to_table: :feature_subscription_types }
  end
end
