class AddBankReimbursementOptionInFeatureSubscription < ActiveRecord::Migration[4.2]
  def change
    add_column :feature_subscriptions, :bank_account_reimbursement, :boolean
  end
end
