class AddEnabledToAutoReloadConfigs < ActiveRecord::Migration[4.2]
  def change
    add_column :auto_reload_configs, :enabled, :boolean, default: false
  end
end
