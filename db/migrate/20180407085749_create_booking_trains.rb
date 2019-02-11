class CreateBookingTrains < ActiveRecord::Migration[4.2]
  def change
    create_table :booking_trains do |t|
      t.string :journey_source
      t.string :journey_destination
      t.date :journey_date
      t.string :departure_time
      t.string :train_number
      t.string :pnr

      t.references :booking, index: true, foreign_key: true
      t.references :booking_request, index: true, foreign_key: true
      t.references :booking_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
