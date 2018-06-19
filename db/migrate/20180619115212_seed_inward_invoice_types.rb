class SeedInwardInvoiceTypes < ActiveRecord::Migration
  def change
    InwardInvoiceType.seed_data
  end
end
