class SecurityPolicy::Enforcers::Password < SecurityPolicy::Enforcers::Base

  bus SecurityPolicy::Manager
  subscribe :password

  def minimum_score(options={})
    SecurityPolicy::Config.config_for(user_role_names, :password, :minimum_score).max || 1
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

  def expire_after(options={})
    SecurityPolicy::Config.config_for(user_role_names, :password, :expire_after).min
  end

end