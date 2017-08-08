class SeedPaymentPurposeTable < ActiveRecord::Migration
  def change
    PaymentPurpose.seed_data
  end
end
