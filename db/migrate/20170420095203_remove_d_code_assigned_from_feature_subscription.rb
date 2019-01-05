class RemoveDCodeAssignedFromFeatureSubscription < ActiveRecord::Migration[4.2]
  def change
    remove_column :feature_subscriptions, :d_code_assigned
  end
end
