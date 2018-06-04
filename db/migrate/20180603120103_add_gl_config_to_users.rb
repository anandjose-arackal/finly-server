class AddGlConfigToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gl_config, :text
  end
end
