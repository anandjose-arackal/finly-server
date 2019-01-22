class AddInfoToBookingEntities < ActiveRecord::Migration[4.2]
  def change
    add_column :booking_flights, :journey_date, :date
    add_column :booking_flights, :booking_class, :string
    add_column :booking_flights, :stops, :string
    add_column :booking_flights, :ticket_number, :string


    add_column :booking_trains, :booking_class, :string
    add_column :booking_trains, :boarding_station_name, :string


    add_column :booking_buses, :boarding_point, :string
    add_column :booking_buses, :booking_class, :string

    add_column :booking_hotels, :hotel_rating, :string

    add_column :booking_restaurants, :restaurant_rating, :string


    add_column :booking_requests, :note, :text
    add_column :bookings, :note, :text

    create_table :booking_customs do |t|
      t.date :journey_date
      t.string :journey_destination
      t.string :journey_source

      t.references :parent, polymorphic: true, index: true

      t.timestamps null: false
    end

  end
end
