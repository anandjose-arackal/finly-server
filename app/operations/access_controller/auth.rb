class AccessController::Auth

  MAX_FAILED_ATTEMPTS = 5
  LOCK_PERIOD = 60.minutes

  def self.failed_attempt(user)
    return if user.nil?
    return if is_locked?(user)
    user.failed_attempts += 1
    lock(skip_save: true)
    user.save if user.failed_attempts >= MAX_FAILED_ATTEMPTS
  end

  def self.is_locked?(user)
    user.locked_at and ((DateTime.now.to_i - user.locked_at.to_i) < LOCK_PERIOD)
  end

  def self.lock(user, options={})
    user.locked_at = DateTime.now
    user.save unless !!options[:skip_save]
  end

  def self.unlock(user)
    user.failed_attempts = 0
    user.locked_at = nil
    user.save
  end

  def self.login(user)

  end

end