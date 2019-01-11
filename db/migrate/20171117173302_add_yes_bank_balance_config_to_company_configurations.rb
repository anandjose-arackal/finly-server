class AddYesBankBalanceConfigToCompanyConfigurations < ActiveRecord::Migration[4.2]
  def change
    add_column :feature_subscriptions, :yes_bank_api_enabled, :boolean
  end
end
