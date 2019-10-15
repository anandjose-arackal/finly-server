class RenameColumnInFeatureSubscription < ActiveRecord::Migration[5.2]
  def change
    rename_column :feature_subscriptions, :gstin_verification_eabled, :gstin_verification_enabled
  end
end
