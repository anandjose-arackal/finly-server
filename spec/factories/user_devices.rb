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

FactoryBot.define do
  factory :user_device do
    user_id { 1 }
    company_id { 1 }
    fingerprint { "MyString" }
    otp_verified { false }
    otp { "MyString" }
    otp_sent_at { "2019-02-18 08:56:28" }
    otp_verified_at { "2019-02-18 08:56:28" }
    otp_count { 1 }
    otp_failed_attempts { 1 }
  end
end
