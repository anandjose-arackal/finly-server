class AddLastPaidDateToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_biller_subscriptions, :last_paid_at, :datetime
    add_column :bbps_bills, :paid_at, :datetime
  end
end
