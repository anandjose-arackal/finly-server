class SeedInwardInvoiceTypes < ActiveRecord::Migration[4.2]
  def change
    InwardInvoiceType.seed_data
  end
end
