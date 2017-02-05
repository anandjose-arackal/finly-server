class EditUsersTableToNewSignUpFlow < ActiveRecord::Migration
  def change
    remove_column :users, :default_password
  end
end
