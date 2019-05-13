class SecurityPolicy::Password

  def self.min_password_score(user)
    SecurityPolicy::Config.config_for(user, :password, :min_score).max
  end

  def self.mandate_special_chars?(user)
    SecurityPolicy::Config.config_for(user, :password, :mandate_special_character).include?(true)
  end

  def self.mandate_numbers?(user)
    SecurityPolicy::Config.config_for(user, :password, :mandate_numbers).include?(true)
  end

  def self.mandate_uppercase?(user)
    SecurityPolicy::Config.config_for(user, :password, :mandate_uppercase).include?(true)
  end

  def self.mandate_lowercase?(user)
    SecurityPolicy::Config.config_for(user, :password, :mandate_lowercase).include?(true)
  end

  def self.min_length(user)
    SecurityPolicy::Config.config_for(user, :password, :min_length).max
  end

  def self.expire_after?(user)
    expire_after = SecurityPolicy::Config.config_for(user, :password, :expire_after).reject {|item| item.blank?}
    expire_after.min
  end

end