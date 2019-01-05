class EditUsersTableToNewSignUpFlow < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :default_password
  end
end
