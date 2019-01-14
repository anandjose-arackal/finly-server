class AddDefaultPasswordToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :default_password, :boolean
  end
end
