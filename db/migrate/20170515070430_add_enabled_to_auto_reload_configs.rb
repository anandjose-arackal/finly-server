class AddEnabledToAutoReloadConfigs < ActiveRecord::Migration
  def change
    add_column :auto_reload_configs, :enabled, :boolean, default: false
  end
end
