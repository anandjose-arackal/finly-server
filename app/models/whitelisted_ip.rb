# == Schema Information
#
# Table name: whitelisted_ips
#
#  id                      :integer          not null, primary key
#  ip_address              :string(255)      not null
#  company_id              :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  whitelisted_ip_types_id :integer          not null
#  whitelisted_ip_type_id  :integer          not null
#

class WhitelistedIp < ActiveRecord::Base
  belongs_to :company
  belongs_to :whitelisted_ip_type

  scope :with_ip, -> (ip) { where ip_address: ip }
  scope :with_type, -> (type) {where whitelisted_ip_type_id: type}
end
