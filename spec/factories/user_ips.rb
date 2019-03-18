# == Schema Information
#
# Table name: user_ips
#
#  id                                :bigint(8)        not null, primary key
#  ip                                :string(255)      not null
#  ip_type                           :string(255)      not null
#  user_id                           :integer          not null
#  status_id                         :integer          not null
#  verification_mode                 :string(255)
#  verification_key                  :string(255)
#  verification_code_sent_at         :datetime
#  verified_at                       :datetime
#  verification_code_count           :integer
#  verification_code_failed_attempts :integer
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#

FactoryBot.define do
  factory :user_ip do
    ip {Faker::Internet.ip_v4_address}
    ip_type {'ipv4'}
    verification_mode {nil}
    verification_key {nil}
    verification_code_sent_at {nil}
    verified_at {nil}
    verification_code_count {0}
    verification_code_failed_attempts {0}
    status_id {UserIpStatus.id_for(:unverified)}

    factory :user_ip_verified do
      status_id {UserIpStatus.id_for(:verified)}
      verified_at {DateTime.now}
    end

    factory :user_ip_unverified do
      status_id {UserIpStatus.id_for(:unverified)}
    end
  end
end
