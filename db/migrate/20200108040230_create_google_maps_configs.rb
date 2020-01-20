class CreateGoogleMapsConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :google_maps_configs do |t|
      t.string :device, index: true, null: false
      t.string :api_token, null: false

      t.timestamps
    end
    GoogleMapsConfig.seed_data
  end
end