class AddVpAppVersionToUserProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :user_profiles, :vp_web_client_version, :string, index: true
    add_column :user_profiles, :vp_web_client_theme, :string, index: true
    add_column :user_profiles, :em_web_client_version, :string, index: true
    add_column :user_profiles, :em_web_client_theme, :string, index: true
  end
end