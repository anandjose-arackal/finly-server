class SeedAgreementPaymentStatus < ActiveRecord::Migration[5.2]
  def change
    AgreementPaymentStatus.seed_data
  end
end
