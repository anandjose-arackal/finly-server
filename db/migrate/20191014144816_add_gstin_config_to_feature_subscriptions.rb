class AddGstinConfigToFeatureSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :feature_subscriptions, :gstin_verification_enabled, :boolean, default: false
  end
end
