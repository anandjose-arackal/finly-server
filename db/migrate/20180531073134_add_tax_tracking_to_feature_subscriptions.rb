class AddTaxTrackingToFeatureSubscriptions < ActiveRecord::Migration
  def change
    add_column :feature_subscriptions, :em_tax_tracking, :boolean, default: false
  end
end
