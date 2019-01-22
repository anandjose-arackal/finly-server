class CreateBookingHotels < ActiveRecord::Migration[4.2]
  def change
    create_table :booking_hotels do |t|
      t.string :reservation_destination
      t.date :reservation_start_date
      t.string :reservation_time
      t.date :reservation_end_date
      t.string :hotel_name

      t.references :booking, index: true, foreign_key: true
      t.references :booking_request, index: true, foreign_key: true
      t.references :booking_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
