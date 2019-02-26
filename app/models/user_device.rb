# == Schema Information
#
# Table name: user_devices
#
#  id                           :bigint(8)        not null, primary key
#  user_id                      :integer
#  company_id                   :integer
#  fingerprint                  :string(255)
#  status_id                    :integer          not null
#  type_id                      :integer          not null
#  verification_mode            :string(255)
#  verification_key             :string(255)
#  verification_code_sent_at    :datetime
#  verified_at                  :datetime
#  verification_code_count      :integer
#  verification_failed_attempts :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  user_device_browser_id       :integer          not null
#

class UserDevice < ApplicationRecord

  DEVICES = {
      browser: {
          klass: UserDeviceBrowser,
          user_device_type: UserDeviceType.id_for(:browser),
          device_key: 13,
          authentication_scope: :web,
          user_device_key: :user_device_browser
      }
  }

  belongs_to :user_device_browser, optional: true, dependent: :destroy
  has_many :user_sessions
  belongs_to :status, class_name: 'UserDeviceStatus'
  belongs_to :type, class_name: 'UserDeviceType'
  belongs_to :user
  belongs_to :company

  validates :status_id, presence: true

  scope :not_incomplete, -> {where.not(status_id: UserDeviceStatus.id_for(:incomplete))}
  scope :find_by_property, ->(user, device_property) {find_by type_id: device_property.type_id, user_device_browser_id: device_property.id, user_id: user.id}

  def incomplete?
    device_property.nil? or device_property&.incomplete?
  end

  def device_property
    case type_id
    when UserDeviceType.id_for(:browser)
      return user_device_browser
    when UserDeviceType.id_for(:android_app)

    when UserDeviceType.id_for(:ios_app)

    when UserDeviceType.id_for(:api)

    else
      nil
    end
  end

end
