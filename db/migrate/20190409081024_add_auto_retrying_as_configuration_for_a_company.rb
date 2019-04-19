class AddAutoRetryingAsConfigurationForACompany < ActiveRecord::Migration[5.2]
  def change
    add_column :company_configurations, :auto_retry_payment, :boolean, default: false
  end
end
