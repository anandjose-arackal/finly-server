class AddBudgetingSystemToFeatureSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :feature_subscriptions, :budgeting_system, :boolean, default: false
  end
end
