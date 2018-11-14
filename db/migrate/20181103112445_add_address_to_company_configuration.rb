class AddAddressToCompanyConfiguration < ActiveRecord::Migration
  def change
    add_column :company_configurations, :address, :text
  end
end
