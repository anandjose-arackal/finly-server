class RenameDarwinboxSsoField < ActiveRecord::Migration
  def change
    rename_column :company_configurations, :darwinbox_sso_enabled, :sso_enabled
  end
end