class Gcm::Base < BaseOperation
  attr_accessor :profile

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
    end
  end

  def init
    self.profile = user.profile
  end

  def validate
    unless self.profile.present?
      messages[:error] << 'Profile not found'
    end
  end
end