class CreateMapLocationUserQueries < ActiveRecord::Migration[5.2]
  def change
    create_table :map_location_user_queries do |t|
      t.uuid :uuid
      t.references :user, index: true, null: false
      t.string :name
      t.text :address
      t.string :place_id, index: true
      t.integer :map_location_detail_id, index: true, null: false, references: 'map_location_details'
      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end
  end
end
