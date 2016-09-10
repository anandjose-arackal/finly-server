class CreateMoneyRequestTracks < ActiveRecord::Migration
  def change
    create_table :money_request_tracking_actions do |t|
      t.string :name

      t.timestamps null: false
    end
    create_table :money_request_tracks do |t|
      t.references :money_request, index: true, foreign_key: true, null: false
      t.integer :action_user_id,:references => "user", index: true, foreign_key: true
      t.references :money_request_tracking_action, index: true, foreign_key: true
      t.integer :status_id, references: 'money_request_status', index: true, foreign_key: true
      t.integer :user_request_role_id, :references => "user_role", index: true, foreign_key: true
      t.references :payment, index: true, foreign_key: true
      t.string :memo

      t.timestamps null: false
    end
  end
end
