class SecurityPolicy::Enforcers::AccountLock < SecurityPolicy::Enforcers::Base

  def max_attempts(options={})
    SecurityPolicy::Config.config_for(user_role_names, :account_lock, :max_attempts).min
  end

  def within_timeframe(options={})
    SecurityPolicy::Config.config_for(user_role_names, :account_lock, :within_timeframe).min
  end

  def locking_period(options={})
    SecurityPolicy::Config.config_for(user_role_names, :account_lock, :locking_period).max
  end

end