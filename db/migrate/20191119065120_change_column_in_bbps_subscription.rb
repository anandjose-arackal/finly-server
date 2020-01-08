class ChangeColumnInBbpsSubscription < ActiveRecord::Migration[5.2]
  def change
    rename_column :bbps_biller_subscriptions, :expected_due_day, :expected_bill_day
  end
end
