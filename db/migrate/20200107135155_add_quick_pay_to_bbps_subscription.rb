class AddQuickPayToBbpsSubscription < ActiveRecord::Migration[5.2]
  def change
    change_column :bbps_yes_bank_transactions, :quick_pay, :string, default: "N"
    add_column :bbps_biller_subscriptions, :quick_pay, :string, default: "N"
  end
end