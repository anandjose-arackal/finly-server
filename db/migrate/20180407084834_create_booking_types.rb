class CreateBookingTypes < ActiveRecord::Migration[4.2]
  def change


    create_table :booking_types do |t|
      t.string :name

      t.timestamps null: false
    end

    create_table :booking_statuses do |t|
      t.string :name

      t.timestamps null: false
    end

    create_table :booking_requests do |t|
      t.references :booking_status, index: true, foreign_key: true

      t.timestamps null: false
    end

    create_table :bookings do |t|
      t.references :booking_request, index: true, foreign_key: true
      t.references :booking_status, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
