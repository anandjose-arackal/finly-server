class CreateUserSessionWebs < ActiveRecord::Migration[5.2]
  def change
    create_table :user_session_webs do |t|
      t.integer :user_session_id, index: true, foreign_key: true, null: false, references: 'user_sessions'
      t.datetime :timestamp
      t.string :user_agent
      t.string :timezone
      t.string :fingerprint
      t.string :language
      t.string :system_language
      t.string :browser
      t.string :browser_version
      t.string :browser_engine
      t.string :browser_engine_version
      t.string :os_name
      t.string :os_version
      t.integer :screen_width
      t.integer :screen_height
      t.integer :current_resolution_width
      t.integer :current_resolution_height
      t.integer :device_x_dpi
      t.integer :device_y_dpi
      t.integer :color_depth
      t.integer :mouse_pos_x
      t.integer :mouse_pos_y
      t.boolean :java_enabled
      t.string :java_version
      t.boolean :flash_enabled
      t.string :flash_version
      t.boolean :silver_light_enabled
      t.string :silver_light_version
      t.boolean :is_mime_types
      t.string :mime_types_list
      t.text :fonts_list
      t.boolean :is_local_storage
      t.boolean :is_session_storage
      t.boolean :is_cookie
      t.text :plugins

      t.timestamps
    end
    add_column :user_sessions, :accuracy_radius, :integer
    add_column :user_sessions, :username, :string, index: true
  end
end
