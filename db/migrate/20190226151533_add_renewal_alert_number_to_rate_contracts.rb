class AddRenewalAlertNumberToRateContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_contracts, :renewal_alert_number, :integer
  end
end
