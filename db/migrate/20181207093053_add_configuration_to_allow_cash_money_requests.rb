class AddConfigurationToAllowCashMoneyRequests < ActiveRecord::Migration
  def change
    add_column :company_configurations, :cash_money_requests_enabled, :boolean, default: true
  end
end
