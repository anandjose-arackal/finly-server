class CreateCardLoadRequestTracks < ActiveRecord::Migration
  def change
    create_table :card_load_request_tracks do |t|
      t.integer :user_id, references: 'user', index: true, foreign_key: true
      t.integer :controlling_user_id, references: 'user', index: true, foreign_key: true
      t.integer :status_id, references: 'card_load_request_status', index: true, foreign_key: true
      t.integer :received_from_id, references: 'user', index: true, foreign_key: true
      t.integer :forwarding_to_id, references: 'user', index: true, foreign_key: true
      t.integer :previous_tracking_id, references: 'card_load_request_track', index: true, foreign_key: true
      t.integer :next_tracking_id, references: 'card_load_request_track', index: true, foreign_key: true
      t.integer :request_id, references: 'card_load_request', index: true, foreign_key: true
      t.text :memo

      t.timestamps null: false
    end
  end
end
