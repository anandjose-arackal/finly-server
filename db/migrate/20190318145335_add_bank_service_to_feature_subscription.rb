class AddBankServiceToFeatureSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :feature_subscriptions, :bank_service_provider, :string
  end
end
