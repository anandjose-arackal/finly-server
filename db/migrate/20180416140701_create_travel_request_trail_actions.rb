class CreateTravelRequestTrailActions < ActiveRecord::Migration[4.2]
  def change
    create_table :travel_request_trail_actions do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
