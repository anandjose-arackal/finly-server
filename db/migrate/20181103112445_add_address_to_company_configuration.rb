class AddAddressToCompanyConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :company_configurations, :address, :text
  end
end
