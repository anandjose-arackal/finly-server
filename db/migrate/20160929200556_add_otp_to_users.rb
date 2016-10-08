class AddOtpToUsers < ActiveRecord::Migration
  def change
    add_column :users, :otp, :string
    add_column :users, :otp_sent_at, :datetime
    add_column :users, :otp_verified_at, :datetime
    add_column :users, :otp_verified, :boolean, null: false, default: false
    add_column :users, :otp_count, :integer, null: false, default: 0
  end
end
