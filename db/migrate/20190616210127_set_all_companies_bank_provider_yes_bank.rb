class SetAllCompaniesBankProviderYesBank < ActiveRecord::Migration[5.2]
  def change
    FeatureSubscription.update_all(bank_service_provider: "YES")
  end
end
