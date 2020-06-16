class AddVpAppVersionToUserProfile < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Migration.add_column :user_profiles, :vp_web_client_version, :string, index: true
    ActiveRecord::Migration.add_column :user_profiles, :vp_web_client_theme, :string, index: true
    ActiveRecord::Migration.add_column :user_profiles, :em_web_client_version, :string, index: true
    ActiveRecord::Migration.add_column :user_profiles, :em_web_client_theme, :string, index: true
  end
end