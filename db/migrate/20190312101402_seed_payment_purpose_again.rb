class SeedPaymentPurposeAgain < ActiveRecord::Migration[5.2]
  def change
    PaymentPurpose.seed_data
  end
end