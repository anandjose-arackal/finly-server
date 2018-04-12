class SeedDataInvoiceTrailActions < ActiveRecord::Migration
  def change
    OutwardInvoiceTrailAction.seed_data
  end
end
