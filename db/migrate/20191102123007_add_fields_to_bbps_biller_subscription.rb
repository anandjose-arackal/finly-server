class AddFieldsToBbpsBillerSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_biller_subscriptions, :agreement_id, :integer, references: 'PaymentAgreement', index: true, foreign_key: true
    add_column :bbps_biller_subscriptions, :expected_due_day, :string
    add_column :bbps_biller_subscriptions, :controlling_level_id, :integer, references: 'ReviewalLevel', index: true, foreign_key: true
    add_column :bbps_biller_subscriptions, :reminder_day, :string
  end
end
