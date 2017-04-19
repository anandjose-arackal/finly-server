class AddCancelledAsPaymentStatus < ActiveRecord::Migration
  def change
    PaymentStatus.seed_data
    PaymentType.seed_data
  end
end
