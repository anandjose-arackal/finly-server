class AddGlConfigToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :gl_config, :text
  end
end
