class SeedTrailData < ActiveRecord::Migration[5.2]
  def change
    TrailAction.seed_data
    PaymentAgreementStatus.seed_data
  end
end
