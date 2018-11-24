class CreateTrackerVisits < ActiveRecord::Migration
  def change
    create_table :tracker_visits do |t|
      # user
      t.references :user, index: true
      t.references :company, index: true

      # standard
      t.string :ip, index: true, null: false
      t.string :ip_type
      t.text :user_agent
      t.text :referrer
      t.string :referring_domain
      t.text :landing_page

      # technology
      t.string :device, index: true
      t.string :browser
      t.string :os
      t.string :os_version
      t.string :app_version
      t.string :user_agent
      t.string :device_type
      t.string :platform
      t.string :screen_height
      t.string :screen_width

      # location
      t.string :continent_name
      t.string :continent_code
      t.string :country_name
      t.string :country_code
      t.string :region_code
      t.string :region_name
      t.string :city
      t.string :zip
      t.decimal :latitude, precision: 20, scale: 10, index: true
      t.decimal :longitude, precision: 20, scale: 10, index: true

      # utm parameters
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_term
      t.string :utm_content
      t.string :utm_campaign

      t.timestamp :started_at, index: true, null: false

      t.timestamps null: false
    end
  end
end
