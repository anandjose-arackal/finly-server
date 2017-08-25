class CreateMigrationToSeedData < ActiveRecord::Migration
  def change
    BankPaymentRequestStatus.seed_data
    BankPaymentRequestTrailAction.seed_data
    PaymentOrderStatus.seed_data

  end
end
