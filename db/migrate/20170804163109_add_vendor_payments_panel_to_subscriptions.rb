class AddVendorPaymentsPanelToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :user_panel_subscriptions, :yes_bank_account_transfer, :boolean
    add_column :feature_subscriptions, :yes_bank_account, :boolean
  end
end
