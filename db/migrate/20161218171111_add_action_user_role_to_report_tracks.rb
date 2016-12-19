class AddActionUserRoleToReportTracks < ActiveRecord::Migration
  def change
    add_column :report_tracks, :action_user_role_id, :integer, references: "UserRole", foreign_key: true, injdex: true
  end
end
