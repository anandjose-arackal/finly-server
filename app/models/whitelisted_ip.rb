# == Schema Information
#
# Table name: whitelisted_ips
#
#  id                     :integer          not null, primary key
#  ip_address             :string(255)      not null
#  company_id             :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  whitelisted_ip_type_id :integer          not null
#

class WhitelistedIp < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :whitelisted_ip_type, optional: true

  scope :with_ip, -> (ip) { where ip_address: ip }
  scope :with_type, -> (type) {where whitelisted_ip_type_id: type}
end
