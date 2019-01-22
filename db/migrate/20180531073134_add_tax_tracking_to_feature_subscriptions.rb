class AddTaxTrackingToFeatureSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :feature_subscriptions, :em_tax_tracking, :boolean, default: false
  end
end
