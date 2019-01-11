class CreateLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :locations do |t|
      t.integer :locatable_id, index: true
      t.string :locatable_type, index: true
      t.decimal :latitude, precision: 20, scale: 10
      t.decimal :longitude, precision: 20, scale: 10
      t.string :name
      t.text :address

      t.timestamps null: false
    end
  end
end
