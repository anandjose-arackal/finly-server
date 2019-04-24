class AddRenewalAlertPeriodIdToRateContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_contracts, :renewal_alert_period_id, :integer
  end
end
