class SeedInvoiceStatuses < ActiveRecord::Migration[4.2]
  def change
    OutwardInvoiceStatus.seed_data
  end
end
