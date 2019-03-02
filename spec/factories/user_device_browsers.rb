# == Schema Information
#
# Table name: user_devices
#
#  id                           :bigint(8)        not null, primary key
#  user_id                      :integer
#  company_id                   :integer
#  fingerprint                  :string(255)
#  status_id                    :integer          not null
#  verification_mode            :string(255)
#  verification_key             :string(255)
#  verification_code_sent_at    :datetime
#  verified_at                  :datetime
#  verification_code_count      :integer
#  verification_failed_attempts :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  client_id                    :integer
#  client_type                  :string(255)
#  message                      :text(65535)
#

FactoryBot.define do
  factory :user_device_browser do
    user_agent = Faker::Internet.user_agent
    ua_client = DeviceDetector.new(user_agent)

    timestamp {DateTime.now.strftime('%Q')}
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

    UserDeviceStatus.all.each do |status|
      factory :"user_device_browser_#{status.name}" do
        status_id {status.id}
      end
    end

    factory :user_device_browser_mobile do
      is_mobile {true}
    end

  end
end
