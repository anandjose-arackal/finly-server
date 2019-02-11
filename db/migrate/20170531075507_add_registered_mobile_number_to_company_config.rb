class AddRegisteredMobileNumberToCompanyConfig < ActiveRecord::Migration[4.2]
  def change
    add_column :company_configurations, :registered_mobile_number, :string
  end
end
