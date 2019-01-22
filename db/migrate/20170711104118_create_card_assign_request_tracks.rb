class CreateCardAssignRequestTracks < ActiveRecord::Migration[4.2]
  def change
    create_table :card_assign_request_tracks do |t|
      t.references :card_assign_request, index: true, foreign_key: true, null:false
      t.integer :action_resource_id, index: true
      t.string :action_resource_type, index: true
      t.integer :action_id, null: false, references: 'CardAssignRequestTrackAction', index: true, foreign_key: true
      t.text :note

      t.timestamps null: false
    end
  end
end
