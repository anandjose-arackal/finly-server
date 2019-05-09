class SeedInvoiceCreditToNotifierTypes < ActiveRecord::Migration[5.2]
  def change
  	NotifierType.seed_data
  end
end
