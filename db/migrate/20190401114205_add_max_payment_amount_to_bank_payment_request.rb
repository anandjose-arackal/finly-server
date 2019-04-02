class AddMaxPaymentAmountToBankPaymentRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_payment_requests, :max_payment_amount, :decimal, precision: 20, scale: 5, index: true
  end
end
