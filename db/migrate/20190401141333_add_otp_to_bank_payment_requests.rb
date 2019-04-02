class AddOtpToBankPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_payment_requests, :otp, :string
    add_column :bank_payment_requests, :otp_sent_at, :datetime
    add_column :bank_payment_requests, :otp_attempts, :integer
  end
end