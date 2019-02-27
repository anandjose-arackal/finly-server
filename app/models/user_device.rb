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
#

class UserDevice < ApplicationRecord

  DEVICES = {
      browser: {
          klass: UserDeviceBrowser,
          device_key: 13,
          authentication_scope: :web
      }
  }

  belongs_to :client, polymorphic: true, optional: true, dependent: :destroy
  has_many :user_sessions
  belongs_to :status, class_name: 'UserDeviceStatus'
  belongs_to :user
  belongs_to :company

  validates :status_id, presence: true
  validates :client, presence: true

  scope :not_incomplete, -> {where.not(status_id: UserDeviceStatus.id_for(:incomplete))}
  scope :valid, -> {where status_id: UserDeviceStatus.ids_for(:unverified, :verified)}
  scope :find_by_client, -> (client) {find_by(client: client)}

  def incomplete?
    client.nil? or client&.incomplete?
  end

end
