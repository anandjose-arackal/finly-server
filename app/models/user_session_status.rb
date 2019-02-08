# == Schema Information
#
# Table name: user_session_statuses
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserSessionStatus < ApplicationRecord
  include Seedable

  # Authorized -> Currently signed in
  # Revoked -> Because of changes in IP Address, Fingerprint etc
  # Blocked -> User account locked and other blockers etc
  # Failed -> invalid password, invalid username
  # Expired -> due to inactivity
  # Logged Out -> When user successfully logs out
  # rubocop:disable SymbolArray
  def self.values
    [:authorized, :revoked, :blocked, :failed, :expired, :logged_out]
  end
  # rubocop:enable SymbolArray

end
