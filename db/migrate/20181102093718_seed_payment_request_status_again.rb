class SeedPaymentRequestStatusAgain < ActiveRecord::Migration[4.2]
  def change
    BankPaymentRequestStatus.seed_data
    PaymentOrderStatus.seed_data
  end
end
