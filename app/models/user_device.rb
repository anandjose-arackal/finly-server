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

  belongs_to :user_device_browser
  has_many :user_sessions
  belongs_to :status, class_name: 'UserDeviceStatus'
  belongs_to :type, class_name: 'UserDeviceType'

  scope :find_by_property, ->(user, device_property) do
    find_by type_id: device_property.type_id, user_device_browser_id: device_property.id, user_id: user.id
  end
  
end
