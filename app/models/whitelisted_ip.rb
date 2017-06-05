class WhitelistedIp < ActiveRecord::Base
  belongs_to :company
  belongs_to :whitelisted_ip_type

  scope :with_ip, -> (ip) { where ip_address: ip }
  scope :with_type, -> (type) {where whitelisted_ip_type_id: type}
end
