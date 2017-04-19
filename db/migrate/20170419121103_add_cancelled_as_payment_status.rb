class AddCancelledAsPaymentStatus < ActiveRecord::Migration
  def change
    PaymentStatus.seed_data
  end
end
