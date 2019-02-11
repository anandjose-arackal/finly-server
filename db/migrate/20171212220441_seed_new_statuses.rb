class SeedNewStatuses < ActiveRecord::Migration[4.2]
  def change
    BankPaymentRequestStatus.seed_data
  end
end
