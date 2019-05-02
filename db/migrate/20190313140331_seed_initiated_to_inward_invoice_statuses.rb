class SeedInitiatedToInwardInvoiceStatuses < ActiveRecord::Migration[5.2]
  def change
  	InwardInvoiceStatus.seed_data
  end
end

