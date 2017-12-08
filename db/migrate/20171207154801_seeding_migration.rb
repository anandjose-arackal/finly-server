class SeedingMigration < ActiveRecord::Migration
  def change
    BankPaymentRequestTrailAction.seed_data
  end
end
