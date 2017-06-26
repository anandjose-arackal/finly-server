class AddOtpVerifiedToItzCashDmtSender < ActiveRecord::Migration
  def change
    add_column :itz_cash_dmt_senders, :otp_verified, :boolean, null: false, default: false
  end
end
