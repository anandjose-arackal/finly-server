class SeedRequestrTrailActions < ActiveRecord::Migration[4.2]
  def change
    BankPaymentRequestTrailAction.seed_data
  end
end
