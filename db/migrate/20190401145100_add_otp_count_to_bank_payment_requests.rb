class AddOtpCountToBankPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_payment_requests, :otp_count, :integer
  end
end
