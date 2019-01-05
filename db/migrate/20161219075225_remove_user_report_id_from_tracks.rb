class RemoveUserReportIdFromTracks < ActiveRecord::Migration[4.2]
  def change
    remove_column :report_tracks, :user_report_role_id
    remove_column :money_request_tracks, :user_request_role_id
  end
end
