class SeedInwardInvoiceSatuses < ActiveRecord::Migration[4.2]
  def change
    InwardInvoiceStatus.seed_data
  end
end
