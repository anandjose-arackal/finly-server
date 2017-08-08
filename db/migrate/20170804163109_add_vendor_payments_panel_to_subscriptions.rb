class AddVendorPaymentsPanelToSubscriptions < ActiveRecord::Migration
  def change
    add_column :user_panel_subscriptions, :yes_bank_account_transfer, :boolean
    add_column :feature_subscriptions, :yes_bank_account, :boolean
  end
end
