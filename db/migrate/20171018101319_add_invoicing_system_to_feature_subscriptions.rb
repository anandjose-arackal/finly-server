class AddInvoicingSystemToFeatureSubscriptions < ActiveRecord::Migration
  def change
    add_column :feature_subscriptions, :invoicing_system, :boolean, default: false
    add_column :user_panel_subscriptions, :invoicing_system, :boolean, default: false
  end
end
