class AddMoreAttributesToSsoConfigs < ActiveRecord::Migration[5.2]
  def change
    add_column :single_sign_on_configurations, :finly_sso_path, :string

  end
end
