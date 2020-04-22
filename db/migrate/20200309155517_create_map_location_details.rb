class CreateMapLocationDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :map_location_details do |t|
      t.uuid :uuid
      t.string :icon
      t.string :name, index: true
      t.string :place_id, index: true
      t.string :url
      t.text :address, limit: 4294967295
      t.text :result, limit: 4294967295
      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end
  end
end
