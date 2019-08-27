class AddIpToUserSessionEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :user_session_events, :ip, :string, index: true
  end
end
