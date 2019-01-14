class AddDelegatedActionUserIdToReportTrack < ActiveRecord::Migration[4.2]
  def change
    add_column :report_tracks, :delegated_action_user_id, :integer
  end
end
