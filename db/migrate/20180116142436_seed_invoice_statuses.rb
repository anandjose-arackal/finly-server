class SeedInvoiceStatuses < ActiveRecord::Migration
  def change
    OutwardInvoiceStatus.seed_data
  end
end
