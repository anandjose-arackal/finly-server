class AddYesBankApiEnabledForAllVpCompanies < ActiveRecord::Migration[4.2]
  def change
    FeatureSubscription.all.each do |fs|
      if [2, 10, 15, 21, 22, 37, 40, 47, 49].include?(fs.subscribable_id)
        fs.update(yes_bank_api_enabled: true)
      end
    end
  end
end
