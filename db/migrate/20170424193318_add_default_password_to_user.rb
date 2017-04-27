class AddDefaultPasswordToUser < ActiveRecord::Migration
  def change
    add_column :users, :default_password, :boolean, default: false
  end
end
