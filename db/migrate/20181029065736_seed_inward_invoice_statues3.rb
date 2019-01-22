class SeedInwardInvoiceStatues3 < ActiveRecord::Migration[4.2]
  def change
    InwardInvoiceType.seed_data
  end
end
