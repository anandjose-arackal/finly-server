class CreateTripPassengers < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_passengers do |t|
      t.uuid
      t.references :trip, index: true, null: false, foreign_key: true
      t.string :name
      t.string :contact_number
      t.string :email
    end
  end
end
