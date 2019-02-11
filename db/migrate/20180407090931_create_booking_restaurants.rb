class CreateBookingRestaurants < ActiveRecord::Migration[4.2]
  def change
    create_table :booking_restaurants do |t|
      t.string :reservation_destination
      t.date :reservation_date
      t.string :reservation_time
      t.string :restaurant_name

      t.references :booking, index: true, foreign_key: true
      t.references :booking_request, index: true, foreign_key: true
      t.references :booking_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
