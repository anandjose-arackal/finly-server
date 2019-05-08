class SeedVendorConfirmedToProcurementStatus < ActiveRecord::Migration[5.2]
  def change
  	ProcurementStatus.seed_data
  end
end
