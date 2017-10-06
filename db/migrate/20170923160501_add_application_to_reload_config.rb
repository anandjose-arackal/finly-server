class AddApplicationToReloadConfig < ActiveRecord::Migration
  def change
    add_column :auto_reload_configs, :application, :string
  end
end
