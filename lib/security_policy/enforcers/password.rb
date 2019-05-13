class SecurityPolicy::Enforcers::Password < SecurityPolicy::Enforcers::Base

  def min_password_score(options={})
    SecurityPolicy::Config.config_for(user_role_names, :password, :min_score).max
  end

  def mandate_special_chars?(options={})
    SecurityPolicy::Config.config_for(user_role_names, :password, :mandate_special_character).include?(true)
  end

  def mandate_numbers?(options={})
    SecurityPolicy::Config.config_for(user_role_names, :password, :mandate_numbers).include?(true)
  end

  def mandate_uppercase?(options={})
    SecurityPolicy::Config.config_for(user_role_names, :password, :mandate_uppercase).include?(true)
  end

  def mandate_lowercase?(options={})
    SecurityPolicy::Config.config_for(user_role_names, :password, :mandate_lowercase).include?(true)
  end

  def min_length(options={})
    SecurityPolicy::Config.config_for(user_role_names, :password, :min_length).max
  end

  def expire_after(options={})
    expire_after = SecurityPolicy::Config.config_for(user_role_names, :password, :expire_after).reject {|item| item.blank?}
    expire_after.min
  end

end