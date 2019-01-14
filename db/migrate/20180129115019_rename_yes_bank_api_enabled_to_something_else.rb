class RenameYesBankApiEnabledToSomethingElse < ActiveRecord::Migration[4.2]
  def change
    rename_column :feature_subscriptions, :yes_bank_api_enabled, :current_account_connected
    FeatureSubscription.update_all(current_account_connected: false)
  end
end
