class AddConfigurationToFeatureSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :feature_subscriptions, :sso_login_enforced, :boolean, default: false
  end
end
