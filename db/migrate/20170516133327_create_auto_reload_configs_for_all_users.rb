class CreateAutoReloadConfigsForAllUsers < ActiveRecord::Migration
  def change
    remove_column :auto_reload_configs, :parent_id, :integer
    remove_column :auto_reload_configs, :parent_type, :string
    add_reference :auto_reload_configs, :reloadable, polymorphic: true, index: true
    User.all.each do |user|
      user.build_auto_reload_config(enabled: false).save
    end
  end
end
