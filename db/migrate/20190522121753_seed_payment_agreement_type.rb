class SeedPaymentAgreementType < ActiveRecord::Migration[5.2]
  def change
    PaymentAgreementType.seed_data
  end
end
