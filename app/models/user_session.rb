# frozen_string_literal: true
# == Schema Information
#
# Table name: user_sessions
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  company_id                  :integer
#  ip                          :string(255)      not null
#  ip_type                     :string(255)
#  referrer                    :text(65535)
#  referring_domain            :string(255)
#  landing_page                :text(65535)
#  app_version                 :string(255)
#  continent_name              :string(255)
#  continent_code              :string(255)
#  country_name                :string(255)
#  country_code                :string(255)
#  region_code                 :string(255)
#  region_name                 :string(255)
#  city                        :string(255)
#  zip                         :string(255)
#  latitude                    :decimal(20, 10)
#  longitude                   :decimal(20, 10)
#  utm_source                  :string(255)
#  utm_medium                  :string(255)
#  utm_term                    :string(255)
#  utm_content                 :string(255)
#  utm_campaign                :string(255)
#  started_at                  :datetime         not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  access_token_id             :integer
#  last_request_at             :datetime
#  duration                    :bigint(8)
#  status_id                   :integer
#  message                     :string(255)
#  login_username              :string(255)
#  accuracy_radius             :integer
#  username                    :string(255)
#  user_device_id              :integer
#  user_agent                  :text(65535)
#  user_ip_id                  :integer
#  user_agent_id               :integer
#  user_agent_client_id        :integer
#  admin_user_id               :integer
#  admin_access_reason         :text(65535)
#  admin_access_reason_details :text(65535)
#  scopes                      :string(255)
#

class UserSession < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :admin_user, optional: true
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
  scope :web, -> {where(scopes: 'web')}
  scope :mobile, -> {where(scopes: 'mobile')}
  scope :admin, -> {where(scopes: 'admin')}
  scope :api, -> {where(scopes: 'api')}
  scope :admin_bypass, -> {where(scopes: 'admin_bypass web')}

  validates :ip, presence: true

  delegate :authorized?, :revoked?, :blocked?, :failed?, :expired?, :logged_out?, to: :status

  def verify(verification_mode)
    self.user_ip.update_attributes(status_id: UserIpStatus.id_for(:verified), verification_mode: verification_mode, verified_at: DateTime.now)
    self.user_agent_client&.update_attributes(status_id: UserAgentClientStatus.id_for(:verified), verification_mode: verification_mode, verified_at: DateTime.now)
    self.user_device&.update_attributes(status_id: UserDeviceStatus.id_for(:verified), verification_mode: verification_mode, verified_at: DateTime.now)
  end

  def verified?
    # Todo temporary workaround as user device, ip, client verification is only implemented for the web
    return true unless web?

    return false unless user_session.user_device.status_id == UserDeviceStatus.id_for(:verified)
    return false unless user_session.user_ip.status_id == UserIpStatus.id_for(:verified)
    return false unless user_session.user_agent_client.status_id == UserAgentClientStatus.id_for(:verified)

    true
  end

  # def scopes
  #   access_token&.scopes.to_s.split(/\W+/)
  # end

  def web?
    scopes == 'web'
  end

  def mobile_app?
    scopes == 'mobile'
  end

  def api?
    scopes == 'api'
  end

  def admin_bypass?
    scopes == 'admin_bypass web'
  end

  # def admin?
  #   scopes == 'admin'
  # end

end
