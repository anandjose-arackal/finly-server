class AddPredictionToFeatureSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :feature_subscriptions, :predictions_enabled, :boolean, default: false, index: true
  end
end
