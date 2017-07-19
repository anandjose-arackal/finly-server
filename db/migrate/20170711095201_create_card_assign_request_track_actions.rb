class CreateCardAssignRequestTrackActions < ActiveRecord::Migration
  def change
    create_table :card_assign_request_track_actions do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    if Company.count > 0
      CardAssignRequestTrackAction.seed_data
    end
  end
end
