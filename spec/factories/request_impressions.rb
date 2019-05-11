# == Schema Information
#
# Table name: request_impressions
#
#  id               :bigint(8)        not null, primary key
#  ip               :string(255)      not null
#  ip_type          :string(255)
#  user_agent       :string(255)
#  username         :string(255)
#  user_id          :integer
#  company_id       :integer
#  referrer         :text(65535)
#  referring_domain :string(255)
#  landing_page     :text(65535)
#  app_version      :string(255)
#  continent_name   :string(255)
#  continent_code   :string(255)
#  country_name     :string(255)
#  country_code     :string(255)
#  region_code      :string(255)
#  region_name      :string(255)
#  city             :string(255)
#  zip              :string(255)
#  latitude         :decimal(20, 10)
#  longitude        :decimal(20, 10)
#  utm_source       :string(255)
#  utm_medium       :string(255)
#  utm_term         :string(255)
#  utm_content      :string(255)
#  utm_campaign     :string(255)
#  http_method      :string(255)      not null
#  app              :string(255)
#  path             :string(255)      not null
#  controller       :string(255)
#  action           :string(255)
#  view             :string(255)
#  blocked          :boolean
#  block_by         :string(255)
#  block_reason     :string(255)
#  response_code    :decimal(10, )
#  response_time    :decimal(10, )
#  user_session_id  :integer
#  access_token_id  :integer
#  user_device_id   :integer
#  user_ip_id       :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  accuracy_radius  :integer
#  blocked_by       :string(255)
#

FactoryBot.define do
  factory :request_impression do
    ip {Faker::Internet.ip_v4_address}
    ip_type {'ipv4'}
    user_agent {Faker::Internet.user_agent}
    controller {'expenses'}
    action {'index'}
    view {'personal'}
    app {'em'}
    path {'/expenses'}
    http_method {'get'}
  end
end
