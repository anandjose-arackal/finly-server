# == Schema Information
#
# Table name: whitelisted_ip_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WhitelistedIpType < ApplicationRecord

  TYPES = {api: 1, admin_panel: 2}

  scope :with_name, -> (name) { where name: name }

  def self.seed_data
    count = WhitelistedIpType.count
    TYPES.each do |key, value|
      if count == 0 or WhitelistedIpType.with_name(key).blank?
        WhitelistedIpType.create id: value, name: key
      end
    end
  end

  def self.id_for(name)
    TYPES[name]
  end

end
