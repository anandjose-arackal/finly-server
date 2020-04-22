class CreateMapLocationSearches < ActiveRecord::Migration[5.2]
  def change
    create_table :map_location_searches do |t|
      t.uuid :uuid
      t.string :input, index: true
      t.text :result, limit: 4294967295

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
