class CreateTravelRequestDestinations < ActiveRecord::Migration[4.2]
  def change
    create_table :travel_request_destinations do |t|
      t.string :name
      t.string :source
      t.references :travel_request, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_column :booking_requests, :travel_request_destination_id, :integer, index: true, foreign_key: true
  end
end
