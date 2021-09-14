class AddPredictionToFeatureSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :feature_subscriptions, :predictions_enabled, :boolean, default: false, index: true

    ActsAsTenant.without_tenant do
      MlModel::Monitor.seed_data
    end
  end
end
