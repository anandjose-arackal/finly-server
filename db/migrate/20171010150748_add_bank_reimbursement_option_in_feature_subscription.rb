class AddBankReimbursementOptionInFeatureSubscription < ActiveRecord::Migration
  def change
    add_column :feature_subscriptions, :bank_account_reimbursement, :boolean
  end
end
