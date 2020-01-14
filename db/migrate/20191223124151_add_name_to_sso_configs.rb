class AddNameToSsoConfigs < ActiveRecord::Migration[5.2]
  def change
    add_column :single_sign_on_configurations, :label, :string
  end
end