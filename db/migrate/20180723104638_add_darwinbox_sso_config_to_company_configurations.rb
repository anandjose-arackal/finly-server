class AddDarwinboxSsoConfigToCompanyConfigurations < ActiveRecord::Migration[4.2]
  def change
    add_column :company_configurations, :darwinbox_sso_enabled, :boolean, default: false
  end
end
