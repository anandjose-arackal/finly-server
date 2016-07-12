class CreateReportTracks < ActiveRecord::Migration
  def change
    create_table :report_tracks do |t|
      t.references :report, index: true, foreign_key: true, null: false
      t.integer :action_user_id,:references => "user", index: true, foreign_key: true
      t.references :report_tracking_action, index: true, foreign_key: true
      t.references :report_status, index: true, foreign_key: true, null:false
      t.string :memo

      t.timestamps null: false
    end
  end
end
