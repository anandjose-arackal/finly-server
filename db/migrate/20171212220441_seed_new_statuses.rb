class SeedNewStatuses < ActiveRecord::Migration
  def change
    BankPaymentRequestStatus.seed_data
  end
end
