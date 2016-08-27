class CreateCardLoadRequestTracks < ActiveRecord::Migration
  def change
    create_table :card_load_tracking_actions do |t|
      t.string :name

      t.timestamps null: false
    end
    create_table :card_load_request_tracks do |t|
      t.references :card_load_request, index: true, foreign_key: true, null: false
      t.integer :action_user_id,:references => "user", index: true, foreign_key: true
      t.references :card_load_tracking_action, index: true, foreign_key: true
      t.integer :status_id, references: 'card_load_request_status', index: true, foreign_key: true
      t.integer :user_request_role_id, :references => "user_role", index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
