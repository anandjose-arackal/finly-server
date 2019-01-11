class CreateReportTracks < ActiveRecord::Migration[4.2]
  def change
    create_table :report_tracks do |t|
      t.references :report, index: true, foreign_key: true, null: false
      t.integer :action_user_id,:references => "user", index: true, foreign_key: true
      t.integer :modified_user_id,:references => "user", index: true, foreign_key: true
      t.references :report_tracking_action, index: true, foreign_key: true
      t.references :report_status, index: true, foreign_key: true, null:false
      t.integer :user_report_role_id, :references => "user_role", index: true, foreign_key: true
      t.integer :modified_user_role_id, :references => "user_role", index: true, foreign_key: true
      t.string :memo

      t.timestamps null: false
    end
  end
end
