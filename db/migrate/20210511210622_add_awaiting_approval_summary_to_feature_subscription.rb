class AddAwaitingApprovalSummaryToFeatureSubscription < ActiveRecord::Migration[6.0]
  def change
    add_column :feature_subscriptions, :awaiting_approval_summary_enabled, :boolean, default: false
  end
end
