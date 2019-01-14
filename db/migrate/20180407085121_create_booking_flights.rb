class CreateBookingFlights < ActiveRecord::Migration[4.2]
  def change


    create_table :booking_flights do |t|
      t.date :departure_date
      t.string :pnr
      t.string :airline
      t.string :journey_destination
      t.string :journey_source

      t.references :booking, index: true, foreign_key: true
      t.references :booking_request, index: true, foreign_key: true
      t.references :booking_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
