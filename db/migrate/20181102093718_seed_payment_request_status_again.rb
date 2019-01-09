class SeedPaymentRequestStatusAgain < ActiveRecord::Migration
  def change
    BankPaymentRequestStatus.seed_data
    PaymentOrderStatus.seed_data
  end
end
