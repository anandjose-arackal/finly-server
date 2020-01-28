class CreateTripPassengers < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_passengers do |t|
      t.uuid
      t.string :trip_id, index: true
      t.string :name
      t.string :contact_number
      t.string :email

      t.timestamps null: false
    end
  end
end
