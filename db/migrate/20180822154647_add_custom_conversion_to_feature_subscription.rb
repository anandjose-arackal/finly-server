class AddCustomConversionToFeatureSubscription < ActiveRecord::Migration
  def change
    add_column :feature_subscriptions, :custom_currency_conversion, :boolean, default: false
  end
end
