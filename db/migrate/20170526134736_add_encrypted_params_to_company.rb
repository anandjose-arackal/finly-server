class AddEncryptedParamsToCompany < ActiveRecord::Migration[4.2]
  def change
    add_column :company_configurations, :encrypted_easy_login_params, :text
  end
end