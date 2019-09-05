class AddAgreementBasedPaymentSystemToFeatureSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :feature_subscriptions, :agreement_based_payment_system, :boolean, default: false
  end
end
