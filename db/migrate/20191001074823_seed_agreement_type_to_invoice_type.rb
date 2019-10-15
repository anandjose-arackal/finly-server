class SeedAgreementTypeToInvoiceType < ActiveRecord::Migration[5.2]
  def change
    InwardInvoiceType.seed_data
  end
end
