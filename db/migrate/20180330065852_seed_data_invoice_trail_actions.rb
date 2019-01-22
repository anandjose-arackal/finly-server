class SeedDataInvoiceTrailActions < ActiveRecord::Migration[4.2]
  def change
    OutwardInvoiceTrailAction.seed_data
  end
end
