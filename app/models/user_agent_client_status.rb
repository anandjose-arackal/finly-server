class UserAgentClientStatus < ApplicationRecord
  include Seedable

  def self.values
    [:unverified, :verified, :blocked]
  end

end
