class AddDetailsToBbpsSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_biller_subscriptions, :mobile_number, :string, index: true
    add_column :bbps_bills, :bill_period, :string
  end
end