class RemoveRenewalAlertFromRateContracts < ActiveRecord::Migration[5.2]
  def change
    remove_column :rate_contracts, :renewal_alert, :string
  end
end
