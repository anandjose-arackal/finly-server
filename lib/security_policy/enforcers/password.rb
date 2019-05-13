class SecurityPolicy::Password < SecurityPolicy::Device::Base

  def min_password_score(user)
    SecurityPolicy::Config.config_for(user, :password, :min_score).max
  end

  def mandate_special_chars?(user)
    SecurityPolicy::Config.config_for(user, :password, :mandate_special_character).include?(true)
  end

  def mandate_numbers?(user)
    SecurityPolicy::Config.config_for(user, :password, :mandate_numbers).include?(true)
  end

  def mandate_uppercase?(user)
    SecurityPolicy::Config.config_for(user, :password, :mandate_uppercase).include?(true)
  end

  def mandate_lowercase?(user)
    SecurityPolicy::Config.config_for(user, :password, :mandate_lowercase).include?(true)
  end

  def min_length(user)
    SecurityPolicy::Config.config_for(user, :password, :min_length).max
  end

  def expire_after?(user)
    expire_after = SecurityPolicy::Config.config_for(user, :password, :expire_after).reject {|item| item.blank?}
    expire_after.min
  end

end