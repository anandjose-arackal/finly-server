class SecurityPolicy::Enforcers::Password < SecurityPolicy::Enforcers::Base

  bus SecurityPolicy::Manager
  subscribe :password

  def minimum_score(options={})
    fetch(:password, :minimum_score).max || 1
  end

  def mandate_special_chars?(options={})
    fetch(:password, :mandate_special_character).include?(true)
  end

  def mandate_numbers?(options={})
    fetch(:password, :mandate_numbers).include?(true)
  end

  def mandate_uppercase?(options={})
    fetch(:password, :mandate_uppercase).include?(true)
  end

  def mandate_lowercase?(options={})
    fetch(:password, :mandate_lowercase).include?(true)
  end

  def expire_after(options={})
    fetch(:password, :expire_after).min
  end

end