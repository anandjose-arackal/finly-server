class AddBillerIdToSubscriptionFields < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_subscription_fields, :biller_id, :integer, references: 'BbpsBiller', foreign_key: true, index: true
  end
end
