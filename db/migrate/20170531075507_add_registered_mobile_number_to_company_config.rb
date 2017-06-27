class AddRegisteredMobileNumberToCompanyConfig < ActiveRecord::Migration
  def change
    add_column :company_configurations, :registered_mobile_number, :string
  end
end
