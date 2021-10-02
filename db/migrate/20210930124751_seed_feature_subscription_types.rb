class SeedFeatureSubscriptionTypes < ActiveRecord::Migration[6.0]
  def change
    FeatureSubscriptionType.seed_data
  end
end
