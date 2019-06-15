class AddUserAgentToUserSession < ActiveRecord::Migration[5.2]
  def change
    add_column :user_sessions, :user_agent, :text
  end
end
