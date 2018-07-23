class AddDarwinboxSsoConfigToCompanyConfigurations < ActiveRecord::Migration
  def change
    add_column :company_configurations, :darwinbox_sso_enabled, :boolean, default: false
  end
end
