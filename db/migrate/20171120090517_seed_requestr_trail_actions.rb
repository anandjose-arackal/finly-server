class SeedRequestrTrailActions < ActiveRecord::Migration
  def change
    BankPaymentRequestTrailAction.seed_data
  end
end
