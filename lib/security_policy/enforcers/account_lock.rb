class SecurityPolicy::Enforcers::AccountLock < SecurityPolicy::Enforcers::Base

  bus SecurityPolicy::Manager
  subscribe :account_lock

  def max_attempts(options={})
    fetch(:account_lock, :max_attempts).min
  end

  def within_timeframe(options={})
    fetch(:account_lock, :within_timeframe).min
  end

  def locking_period(options={})
    fetch(:account_lock, :locking_period).max
  end

end