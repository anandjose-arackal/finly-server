# == Schema Information
#
# Table name: user_ips
#
#  id                                :bigint           not null, primary key
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
#  continent_name                    :string(255)
#  continent_code                    :string(255)
#  country_name                      :string(255)
#  country_code                      :string(255)
#  region_code                       :string(255)
#  region_name                       :string(255)
#  city                              :string(255)
#  zip                               :string(255)
#  latitude                          :decimal(20, 10)
#  longitude                         :decimal(20, 10)
#  accuracy_radius                   :integer
#

class UserIp < ApplicationRecord

  belongs_to :user
  belongs_to :status, class_name: 'UserIpStatus'

  scope :verified, -> {where status_id: UserIpStatus.id_for(:verified)}

end
