class AddYesBankBalanceConfigToCompanyConfigurations < ActiveRecord::Migration
  def change
    add_column :feature_subscriptions, :yes_bank_api_enabled, :boolean
  end
end
