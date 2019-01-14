class AddDefaultsToExpenseBooleans < ActiveRecord::Migration[4.2]
  def change
    change_column :expenses, :synced_with_quickbooks, :boolean, default: false
    change_column :expenses, :from_cash_on_hand, :boolean, default: false
    PaymentPurpose.seed_data
  end
end
