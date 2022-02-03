class ChangeFeatureSubscription < ActiveRecord::Migration[6.0]
  def change
    add_column :feature_subscriptions, :paid_by_company_pocket_enabled, :boolean

  end
end
