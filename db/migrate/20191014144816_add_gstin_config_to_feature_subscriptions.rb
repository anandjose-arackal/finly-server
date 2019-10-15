class AddGstinConfigToFeatureSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :feature_subscriptions, :gstin_verification_eabled, :boolean, default: false
  end
end
