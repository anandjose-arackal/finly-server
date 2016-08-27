class AddActionToTracks < ActiveRecord::Migration
  def change
    add_column :card_load_request_tracks, :action_id, :integer, references: 'card_load_request_action', index: true, foreign_key: true
  end
end
