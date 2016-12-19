class ActionUserRoleIdToMonwyRequestTracks < ActiveRecord::Migration
  def change
    add_column :money_request_tracks, :action_user_role_id, :integer, references: "UserRole", foreign_key: true, index: true
  end
end
