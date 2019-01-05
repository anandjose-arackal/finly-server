class CreateWebHookTracks < ActiveRecord::Migration[4.2]
  def change
    create_table :web_hook_tracks do |t|
      t.references :web_hook, index: true, foreign_key: true
      t.references :web_hook_event, index: true, foreign_key: true
      t.references :company, index: true, foreign_key: true
      t.text :url
      t.text :request_body
      t.text :request_header
      t.decimal :response_time
      t.text :response_body
      t.integer :response_status
      t.integer :attempt
      t.datetime :last_attempted_at
      t.boolean :attempt_success

      t.timestamps null: false
    end
  end
end
