class CreateRequestImpressions < ActiveRecord::Migration[5.2]
  def change
    create_table :request_impressions do |t|
      t.string :ip, null: false, index: true
      t.string :ip_type
      t.string :user_agent, index: true
      t.string :username, index: true
      t.integer :user_id, index: true, foreign_key: true, references: 'users'
      t.integer :company_id, index: true, foreign_key: true, references: 'companies'
      t.text :referrer
      t.string :referring_domain
      t.text :landing_page
      t.string :app_version
      t.string :continent_name
      t.string :continent_code
      t.string :country_name, index: true
      t.string :country_code
      t.string :region_code
      t.string :region_name
      t.string :city
      t.string :zip
      t.decimal :latitude, precision: 20, scale: 10
      t.decimal :longitude, precision: 20, scale: 10
      t.integer :accuracy_radius
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_term
      t.string :utm_content
      t.string :utm_campaign
      t.string :http_method, null: false
      t.string :app, index: true
      t.string :path, null: false, index: true
      t.string :controller, index: true
      t.string :action, index: true
      t.string :view
      t.boolean :blocked, index: true
      t.string :blocked_by, index: true
      t.string :block_reason, index: true
      t.decimal :response_code, index: true
      t.decimal :response_time, index: true
      t.integer :user_session_id, index: true, foreign_key: true, references: 'user_sessions'
      t.integer :access_token_id, references: 'oauth_access_tokens', index: true, foreign_key: true
      t.integer :user_device_id, references: 'user_devices', index: true, foreign_key: true
      t.integer :user_ip_id, references: 'user_ips', index: true, foreign_key: true

      t.timestamps
    end
  end
end
