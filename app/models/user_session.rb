# frozen_string_literal: true
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
#  user_agent_client_id :integer
#  admin_user_id        :integer
#

class UserSession < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :company, optional: true
  belongs_to :access_token, class_name: 'Doorkeeper::AccessToken', optional: true
  belongs_to :status, class_name: 'UserSessionStatus'
  belongs_to :user_ip, optional: true
  belongs_to :user_agent_client, optional: true
  belongs_to :user_device, optional: true

  has_many :events, class_name: 'UserSessionEvent', dependent: :destroy

  accepts_nested_attributes_for :events

  scope :with_user_id, ->(user_id) {where user_id: user_id}
  scope :with_device, ->(device) {where device: device}
  scope :with_ip, ->(ip) {where ip: ip}
  scope :started_after, ->(datetime) {where 'started_at >= ?', datetime}
  scope :authorized, -> {where status_id: UserSessionStatus.id_for(:authorized)}
  scope :web, -> {where client_type: 'UserDeviceBrowser'}

  delegate :authorized?, :revoked?, :blocked?, :failed?, :expired?, :logged_out?, to: :status

  def verify(verification_mode)
    self.user_ip.update_attributes(status_id: UserIpStatus.id_for(:verified), verification_mode: verification_mode, verified_at: DateTime.now)
    self.user_agent_client&.update_attributes(status_id: UserAgentClientStatus.id_for(:verified), verification_mode: verification_mode, verified_at: DateTime.now)
    self.user_device&.update_attributes(status_id: UserDeviceStatus.id_for(:verified), verification_mode: verification_mode, verified_at: DateTime.now)
  end

end
