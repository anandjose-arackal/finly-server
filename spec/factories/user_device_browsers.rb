# == Schema Information
#
# Table name: user_device_browsers
#
#  id                     :bigint(8)        not null, primary key
#  timestamp              :datetime
#  user_agent             :string(255)
#  timezone               :string(255)
#  fingerprint            :string(255)
#  language               :string(255)
#  system_language        :string(255)
#  browser                :string(255)
#  browser_version        :string(255)
#  browser_engine         :string(255)
#  browser_engine_version :string(255)
#  os_name                :string(255)
#  os_version             :string(255)
#  screen_width           :integer
#  screen_height          :integer
#  device_x_dpi           :integer
#  device_y_dpi           :integer
#  color_depth            :integer
#  java_enabled           :boolean
#  java_version           :string(255)
#  flash_enabled          :boolean
#  flash_version          :string(255)
#  silver_light_enabled   :boolean
#  silver_light_version   :string(255)
#  is_mime_types          :boolean
#  mime_types_list        :string(255)
#  fonts_list             :text(65535)
#  is_local_storage       :boolean
#  is_session_storage     :boolean
#  is_cookie              :boolean
#  plugins                :text(65535)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  is_mobile              :boolean
#  status_id              :integer          not null
#  message                :text(65535)
#

FactoryBot.define do
  factory :user_device_browser do
    user_agent = Faker::Internet.user_agent
    ua_client = DeviceDetector.new(user_agent)


    timestamp_s {DateTime.now.strftime('%Q')}
    user_agent {user_agent}
    timezone {'Indian Standard Time'}
    fingerprint {SecureRandom.hex(32)}
    language {'en-IN'}
    system_language {nil}
    browser {ua_client.name}
    browser_version {ua_client.full_version}
    browser_engine {'Webkit'}
    browser_engine_version {'437.20'}
    os_name {ua_client.os_name}
    os_version {ua_client.os_full_version}
    screen_width {'1920'}
    screen_height {'1080'}
    device_x_dpi {nil}
    device_y_dpi {nil}
    color_depth {24}
    java_enabled {false}
    java_version {nil}
    flash_enabled {false}
    flash_version {nil}
    silver_light_enabled {false}
    silver_light_version {nil}
    is_mime_types {true}
    mime_types_list {', Portable Document Format, Native Client Executable, Portable Native Client Executable'}
    fonts_list {'Adobe Fangsong Std, Adobe Hebrew, Adobe Ming Std, Arial Black, Arial, Bauhaus 93, Calibri, Chalkduster, Comic Sans MS, Courier New, Georgia, Hiragino Sans GB, Impact, Kozuka Gothic Pr6N, Menlo, Microsoft Sans Serif, Papyrus, Plantagenet Cherokee, Rockwell, Symbol, Tahoma, Times New Roman, Trebuchet MS, Verdana, Webdings, Wingdings'}
    is_local_storage {true}
    is_session_storage {true}
    is_cookie {true}
    plugins {'Chrome PDF Plugin, Chrome PDF Viewer, Native Client'}
    is_mobile {false}
    status_id {UserDeviceStatus.id_for(:unverified)}

    factory :"user_device_browser_unverified" do
      status_id {UserDeviceStatus.id_for(:unverified)}
    end

    factory :"user_device_browser_verified" do
      status_id {UserDeviceStatus.id_for(:verified)}
    end

    factory :"user_device_browser_incomplete" do
      status_id {UserDeviceStatus.id_for(:incomplete)}
    end

    factory :"user_device_browser_attribute_mismatch" do
      status_id {UserDeviceStatus.id_for(:attribute_mismatch)}
    end

    factory :"user_device_browser_complete" do
      status_id {UserDeviceStatus.id_for(:complete)}
    end

    factory :user_device_browser_mobile do
      is_mobile {true}
    end

  end
end
