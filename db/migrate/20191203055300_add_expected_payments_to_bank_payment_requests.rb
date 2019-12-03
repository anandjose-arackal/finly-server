class AddExpectedPaymentsToBankPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_payment_requests, :expected_payments, :integer, default: 0
  end
end
