class AddDefaultPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :default_password, :boolean
  end
end
