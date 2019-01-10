class RenameDarwinboxSsoField < ActiveRecord::Migration[4.2]
  def change
    rename_column :company_configurations, :darwinbox_sso_enabled, :sso_enabled
  end
end