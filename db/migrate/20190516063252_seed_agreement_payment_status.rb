class SeedAgreementPaymentStatus < ActiveRecord::Migration[5.2]
  def change
    PaymentAgreementStatus.seed_data
  end
end
