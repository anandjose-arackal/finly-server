# == Schema Information
#
# Table name: user_agent_client_statuses
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserAgentClientStatus < ApplicationRecord
  include Seedable

  def self.values
    [:unverified, :verified, :blocked]
  end

end
