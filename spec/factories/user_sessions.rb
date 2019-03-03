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
  factory :user_session do
    ip {Faker::Internet.ip_v4_address}
    ip_type {'ipv4'}
    referrer {'https://www.google.com'}
    referring_domain {'google.com'}
    landing_page {'https://www.finly.io/#expenses'}
    app_version {nil}
    continent_name {'Asia'}
    continent_code {'AS'}
    country_name {'India'}
    country_code {'In'}
    region_code {'BLR'}
    region_name {'Bangalore'}
    city {'India'}
    zip {560098}
    started_at{DateTime.now}
    last_request_at {DateTime.now}
    duration {100}
    status_id {UserSessionStatus.id_for(:authorized)}
    message {nil}
    login_username {'asd'}
    accuracy_radius {'50'}
    username {'asd'}
    client_type {'UserDeviceBrowser'}

    factory :user_session_browser do
      client_type {'UserDeviceBrowser'}
    end
  end
end
