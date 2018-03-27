class SeedPaymentPurpose < ActiveRecord::Migration
  def change
    PaymentPurpose.seed_data
  end
end
