class FeatureSubscriptionType < NonTenantedApplicationRecord
  include Seedable
  def self.values
    %w( expense_management vendor_payments disburse insights)
  end

  def  as_json
    {
        id: id,
        name: name.upcase
    }
  end
end
