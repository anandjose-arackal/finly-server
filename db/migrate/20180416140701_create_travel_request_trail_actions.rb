class CreateTravelRequestTrailActions < ActiveRecord::Migration
  def change
    create_table :travel_request_trail_actions do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
