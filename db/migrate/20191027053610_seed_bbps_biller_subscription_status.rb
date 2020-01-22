class SeedBbpsBillerSubscriptionStatus < ActiveRecord::Migration[5.2]
  def change
    BbpsBillerSubscriptionStatus.seed_data
  end
end
