class SetFeatureFlagItop < ActiveRecord::Migration[6.0]
  def change
    ActsAsTenant.without_tenant do
      Company.all.each do |company|
        next if company.feature_subscription.yes_bank_account != true
        next if [168, 169, 175,49].include?(company.id)
        if company.feature_subscription.procurement
          company.feature_subscription.update_columns(invoice_to_pay_system: true)
        end
      end
    end
  end
end
