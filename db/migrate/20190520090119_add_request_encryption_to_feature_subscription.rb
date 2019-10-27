class AddRequestEncryptionToFeatureSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :feature_subscriptions, :request_encryption_enabled, :boolean, default: false
  end
end
