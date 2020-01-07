class AddFetchRequirementToBbpsSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_biller_subscriptions, :fetch_requirement, :string, index: true
    add_column :bbps_biller_subscriptions, :auto_generate_bill, :boolean, index: true, default: true
    add_column :bbps_biller_subscriptions, :support_bill_validation, :string, index: true

    add_column :bbps_bills, :late_payment_fee_id, :integer, references: 'Amount', foreign_key: true, index: true
    add_column :bbps_bills, :fixed_charge_id, :integer, references: 'Amount', foreign_key: true, index: true
    add_column :bbps_bills, :additional_charge_id, :integer, references: 'Amount', foreign_key: true, index: true
    add_column :bbps_bills, :quick_pay, :boolean, default: :false

    rename_column :bbps_biller_subscriptions, :reminder_day, :reminder_before_days
  end
end
