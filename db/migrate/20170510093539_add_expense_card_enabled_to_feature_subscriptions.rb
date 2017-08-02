class AddExpenseCardEnabledToFeatureSubscriptions < ActiveRecord::Migration
  def change
    add_column :feature_subscriptions, :expense_card_enabled, :boolean, default: false
    add_column :feature_subscriptions, :reimbursement_card_enabled, :boolean, default: false

    PaymentType.seed_data
  end
end
