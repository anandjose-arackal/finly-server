class AddThresholdToPur < ActiveRecord::Migration[5.2]
  def change
    add_column :policy_user_roles, :min_amount, :decimal, precision: 20, scale: 5, default: 0
    add_column :policy_user_roles, :max_amount, :decimal, precision: 20, scale: 5
  end
end
