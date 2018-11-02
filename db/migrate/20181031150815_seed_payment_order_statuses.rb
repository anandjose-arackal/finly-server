class SeedPaymentOrderStatuses < ActiveRecord::Migration
  def change
    PaymentOrderStatus.seed_data
  end
end
