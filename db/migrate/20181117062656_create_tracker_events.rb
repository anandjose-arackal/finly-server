class CreateTrackerEvents < ActiveRecord::Migration
  def change
    create_table :tracker_events do |t|
      t.integer :tracker_visit_id, index: true, foreign_key: true, references: 'TrackerVisit', null: false
      t.string :http_method
      t.string :app, index: true
      t.string :path, index: true
      t.string :controller, index: true, null: false
      t.string :action, index: true, null: false

      t.timestamps null: false
    end
  end
end
