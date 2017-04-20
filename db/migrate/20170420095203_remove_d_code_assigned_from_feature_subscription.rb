class RemoveDCodeAssignedFromFeatureSubscription < ActiveRecord::Migration
  def change
    remove_column :feature_subscriptions, :d_code_assigned
  end
end
