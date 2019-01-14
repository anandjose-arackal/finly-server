class AddOtpAttemptsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :otp_attempts, :integer, default: 0
  end
end
