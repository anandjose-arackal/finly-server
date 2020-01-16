# == Schema Information
#
# Table name: user_ip_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserIpStatus < ApplicationRecord
  include Seedable

  def self.values
    [:unverified, :verified, :blocked]
  end

end
