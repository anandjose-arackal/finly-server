class AddScopesToUserSession < ActiveRecord::Migration[5.2]
  def change
    add_column :user_sessions, :scopes, :string, index: true
    remove_column :user_sessions, :client_type
  end
end
