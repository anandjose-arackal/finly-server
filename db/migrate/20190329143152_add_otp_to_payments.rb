class AddOtpToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :otp, :string
    add_column :payments, :opt_attempts, :integer
  end
end