# == Schema Information
#
# Table name: user_session_statuses
#
#  id         :bigint           not null, primary key
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


  def authorized?
    self.id == UserSessionStatus.id_for(:authorized)
  end

  def revoked?
    self.id == UserSessionStatus.id_for(:revoked)
  end

  def blocked?
    self.id == UserSessionStatus.id_for(:blocked)
  end

  def failed?
    self.id == UserSessionStatus.id_for(:failed)
  end

  def expired?
    self.id == UserSessionStatus.id_for(:expired)
  end

  def logged_out?
    self.id == UserSessionStatus.id_for(:logged_out)
  end

end
