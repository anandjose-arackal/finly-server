class AddApplicationToReloadConfig < ActiveRecord::Migration[4.2]
  def change
    add_column :auto_reload_configs, :application, :string
  end
end
