class CreateGsts < ActiveRecord::Migration[5.2]
  def change
    create_table :gsts do |t|
      t.string :gstin
      t.boolean :verified
      t.json :api_response
      t.integer :gst_location_id

      t.timestamps
    end
  end
end
