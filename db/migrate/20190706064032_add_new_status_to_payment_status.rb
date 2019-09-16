class AddNewStatusToPaymentStatus < ActiveRecord::Migration[5.2]
  def change
    PaymentStatus.seed_data
  end
end
