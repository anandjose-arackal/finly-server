class SeedNewPaymentPurposes < ActiveRecord::Migration[4.2]
  def change
    PaymentPurpose.seed_data
  end
end
