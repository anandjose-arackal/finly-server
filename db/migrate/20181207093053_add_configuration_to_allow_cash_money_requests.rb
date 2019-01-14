class AddConfigurationToAllowCashMoneyRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :company_configurations, :cash_money_requests_enabled, :boolean, default: true
  end
end
