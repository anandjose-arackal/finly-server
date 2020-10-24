class AddEnforceBudgetLimitToFeatureSubscription < ActiveRecord::Migration[6.0]
  def change
    add_column :feature_subscriptions, :enforce_budget_limit, :boolean, default: false
  end
end
