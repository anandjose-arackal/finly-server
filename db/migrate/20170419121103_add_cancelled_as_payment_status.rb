class AddCancelledAsPaymentStatus < ActiveRecord::Migration[4.2]
  def change
    PaymentStatus.seed_data
    PaymentType.seed_data
  end
end
