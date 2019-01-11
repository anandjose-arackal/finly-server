class SeedNewStatusesForPaymentOrder < ActiveRecord::Migration[4.2]
  def change
    PaymentOrderStatus.seed_data
  end
end