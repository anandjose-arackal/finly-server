class SeedInwardInvoiceSatuses < ActiveRecord::Migration
  def change
    InwardInvoiceStatus.seed_data
  end
end
