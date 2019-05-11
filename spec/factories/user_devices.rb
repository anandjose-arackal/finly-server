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
  factory :user_device do
    fingerprint {SecureRandom.hex(32)}
    status_id {UserDeviceStatus.id_for(:unverified)}
    verification_mode {'otp'}
    verification_key {rand(10 ** 6)}
    verification_code_sent_at {DateTime.now}
    verified_at {nil}
    verification_code_count {1}
    verification_failed_attempts {0}
    message {nil}

    factory :"user_device_unverified" do
      status_id {UserDeviceStatus.id_for(:unverified)}
    end

    factory :"user_device_verified" do
      status_id {UserDeviceStatus.id_for(:verified)}
    end

    factory :"user_device_incomplete" do
      status_id {UserDeviceStatus.id_for(:incomplete)}
    end

    factory :"user_device_attribute_mismatch" do
      status_id {UserDeviceStatus.id_for(:attribute_mismatch)}
    end

    factory :"user_device_complete" do
      status_id {UserDeviceStatus.id_for(:complete)}
    end
  end
end
