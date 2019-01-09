class AddDelegatedActionUserIdToReportTrack < ActiveRecord::Migration
  def change
    add_column :report_tracks, :delegated_action_user_id, :integer
  end
end
