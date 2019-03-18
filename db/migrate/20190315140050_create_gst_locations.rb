class CreateGstLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :gst_locations do |t|
      t.string :location_name
      t.integer :state_id
      t.string :state_code
      t.string :point_of_contact
      t.string :mobile
      t.string :email
      t.string :fax
      t.string :designation

      t.timestamps
    end
  end
end
