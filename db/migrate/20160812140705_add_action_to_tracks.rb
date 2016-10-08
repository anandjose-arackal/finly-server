class AddActionToTracks < ActiveRecord::Migration
  def change
    add_column :money_request_tracks, :action_id, :integer, references: 'money_request_action', index: true, foreign_key: true
  end
end
