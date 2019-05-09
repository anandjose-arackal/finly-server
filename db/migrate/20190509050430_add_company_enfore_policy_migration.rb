class AddCompanyEnforePolicyMigration < ActiveRecord::Migration[5.2]
  def change
    Company.joins(:feature_subscription).where('feature_subscriptions.yes_bank_account = ?', true).find_each do |company|
      
      if EnforcePolicy.where(enforceable_id: company.id, enforceable_type: 'Company').blank?
        EnforcePolicy.create(enforceable_id: company.id, enforceable_type: 'Company', enabled: false)
      end
    end
  end
end
