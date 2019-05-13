class AddGeoDataToUserIp < ActiveRecord::Migration[5.2]
  def change
    add_column :user_ips, :continent_name, :string
    add_column :user_ips, :continent_code, :string
    add_column :user_ips, :country_name, :string
    add_column :user_ips, :country_code, :string
    add_column :user_ips, :region_code, :string
    add_column :user_ips, :region_name, :string
    add_column :user_ips, :city, :string
    add_column :user_ips, :zip, :string
    add_column :user_ips, :latitude, :decimal, precision: 20, scale: 10
    add_column :user_ips, :longitude, :decimal, precision: 20, scale: 10
    add_column :user_ips, :accuracy_radius, :integer

    UserIp.all.each do |ip|
      geo_ip = Geocoder.search(ip.ip)
      geo_ip = geo_ip.first if geo_ip.respond_to?(:each)
      data = geo_ip&.data
      ip.continent_name = data&.dig('continent', 'names', 'en')
      ip.continent_code = data&.dig('continent', 'code')
      ip.country_name = data&.dig('country', 'names', 'en')
      ip.country_code = data&.dig('country', 'iso_code')
      ip.region_code = data&.dig('subdivisions')&.first&.dig('iso_code')
      ip.region_name = data&.dig('subdivisions')&.first&.dig('names', 'en')
      ip.city = data&.dig('city', 'names', 'en')
      ip.zip = data&.dig('postal', 'code')
      ip.latitude = data&.dig('location', 'latitude')
      ip.longitude = data&.dig('location', 'longitude')
      ip.accuracy_radius = data&.dig('location', 'accuracy_radius')
      ip.save
    end

    add_column :user_auth_failures, :ip, :string, index: true
    add_column :user_auth_failures, :username, :string, index: true
    add_column :user_auth_failures, :blank_username, :boolean, index: true, default: false
    add_column :user_auth_failures, :blank_password, :boolean, index: true, default: false
    add_column :user_auth_failures, :invalid_username, :boolean, index: true, default: false
    add_column :user_auth_failures, :invalid_password, :boolean, index: true, default: false
    change_column_null :user_auth_failures, :user_id, true
  end
end
