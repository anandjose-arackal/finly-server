class CreateBookingFlightClasses < ActiveRecord::Migration[4.2]
  def change
    create_table :booking_flight_classes do |t|
      t.string :name, index: true, null: false

      t.timestamps null: false
    end
    BookingFlightClass.seed_data
  end
end
