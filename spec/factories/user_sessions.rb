# == Schema Information
#
# Table name: user_sessions
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  company_id           :integer
#  ip                   :string(255)      not null
#  ip_type              :string(255)
#  referrer             :text(65535)
#  referring_domain     :string(255)
#  landing_page         :text(65535)
#  app_version          :string(255)
#  continent_name       :string(255)
#  continent_code       :string(255)
#  country_name         :string(255)
#  country_code         :string(255)
#  region_code          :string(255)
#  region_name          :string(255)
#  city                 :string(255)
#  zip                  :string(255)
#  latitude             :decimal(20, 10)
#  longitude            :decimal(20, 10)
#  utm_source           :string(255)
#  utm_medium           :string(255)
#  utm_term             :string(255)
#  utm_content          :string(255)
#  utm_campaign         :string(255)
#  started_at           :datetime         not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  access_token_id      :integer
#  last_request_at      :datetime
#  duration             :bigint(8)
#  status_id            :integer
#  message              :string(255)
#  login_username       :string(255)
#  accuracy_radius      :integer
#  username             :string(255)
#  user_device_id       :integer
#  client_type          :string(255)
#  user_agent           :text(65535)
#  user_ip_id           :integer
#  user_agent_id        :integer
#  user_agent_client_id :integer
#  admin_user_id        :integer
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
