class AddEncryptedParamsToCompany < ActiveRecord::Migration
  def change
    add_column :company_configurations, :encrypted_easy_login_params, :text
  end
end
