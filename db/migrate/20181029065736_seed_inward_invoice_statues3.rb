class SeedInwardInvoiceStatues3 < ActiveRecord::Migration
  def change
    InwardInvoiceType.seed_data
  end
end
