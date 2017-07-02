class AddItzcashDCodeToFeatures < ActiveRecord::Migration
  def change
    add_column :feature_subscriptions, :itz_cash_d_code_enabled, :boolean, default: false
    Company.all.each do |company|
      company.feature_subscription.update(itz_cash_d_code_enabled: true)
    end
  end
end