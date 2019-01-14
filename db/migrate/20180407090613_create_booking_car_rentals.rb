class CreateBookingCarRentals < ActiveRecord::Migration[4.2]
  def change
    create_table :booking_car_rentals do |t|
      t.string :journey_source
      t.string :journey_destination
      t.text :pickup_address
      t.date :journey_date
      t.string :pickup_time
      t.date :reservation_start_date
      t.date :reservation_end_date
      t.string :car_type
      t.string :car_number

      t.references :booking, index: true, foreign_key: true
      t.references :booking_request, index: true, foreign_key: true
      t.references :booking_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
