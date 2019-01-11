class AddActionUserRoleToReportTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :report_tracks, :action_user_role_id, :integer, references: 'UserRole', foreign_key: true, index: true
  end
end
