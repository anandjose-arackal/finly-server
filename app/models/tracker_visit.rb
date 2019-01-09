# == Schema Information
#
# Table name: tracker_visits
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  company_id       :integer
#  ip               :string(255)      not null
#  ip_type          :string(255)
#  user_agent       :string(255)
#  referrer         :text(65535)
#  referring_domain :string(255)
#  landing_page     :text(65535)
#  device           :string(255)
#  browser          :string(255)
#  os               :string(255)
#  os_version       :string(255)
#  app_version      :string(255)
#  device_type      :string(255)
#  platform         :string(255)
#  screen_height    :string(255)
#  screen_width     :string(255)
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
#  started_at       :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TrackerVisit < ActiveRecord::Base
  belongs_to :user
  belongs_to :company

  has_many :events, class_name: 'TrackerEvent', dependent: :destroy

  scope :with_user_id, -> (user_id) {where user_id: user_id}
  scope :with_device, -> (device) {where device: device}
  scope :with_ip, -> (ip) {where ip: ip}
  scope :started_after, -> (datetime) {where 'started_at >= ?', datetime}

end
