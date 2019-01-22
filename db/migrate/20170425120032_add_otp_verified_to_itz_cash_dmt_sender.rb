class AddOtpVerifiedToItzCashDmtSender < ActiveRecord::Migration[4.2]
  def change
    add_column :itz_cash_dmt_senders, :otp_verified, :boolean, null: false, default: false
  end
end
