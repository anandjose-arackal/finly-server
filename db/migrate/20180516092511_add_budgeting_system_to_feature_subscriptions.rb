class AddBudgetingSystemToFeatureSubscriptions < ActiveRecord::Migration
  def change
    add_column :feature_subscriptions, :budgeting_system, :boolean, default: false
  end
end
