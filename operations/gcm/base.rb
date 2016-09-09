class Gcm::Base < BaseOperation
  attr_accessor :profile

  def pre_validate
    if user.blank?
      errors << 'User not found'
    end
  end

  def init
    self.profile = user.profile
  end

  def validate
    unless self.profile.present?
      errors << 'Profile not found'
    end
  end
end