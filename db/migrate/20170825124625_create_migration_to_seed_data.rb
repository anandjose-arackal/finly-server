class CreateMigrationToSeedData < ActiveRecord::Migration[4.2]
  def change
    BankPaymentRequestStatus.seed_data
    BankPaymentRequestTrailAction.seed_data
    PaymentOrderStatus.seed_data
    PaymentStatus.seed_data
    BankPaymentRequestCommentAction.seed_data
  end
end
