class Gatekeeper::Rules::AccountLock < Gatekeeper::Rules::BaseRule
  index Gatekeeper::Master

  LOCKING_PERIOD = 1.minute

  rule 'If invalid username is entered more than 20 times, throttle the IP', on: :user_login_invalid_username do
    # todo throttle the IP
  end

  rule 'More than 5 failed attempts should lock the account', on: :user_login_invalid_password do
    user = params[:user]
    user.failed_attempts ||= 0
    user.failed_attempts += 1
    if user.failed_attempts >= 5 and not user.locked_at.present?
      user.locked_at = DateTime.now
      add_message :error,' "Too many failed password attempts. Locking the account"'
      response_code 401
    end
    user.save
  end

  rule 'Do not allow locked accounts to login', on: :user_login_attempt do
    user = params[:user]
    if user.locked_at.present? and (Time.now - user.locked_at) < LOCKING_PERIOD
      add_message :error, 'Account has been temporarily locked. Please try after sometime'
      response_code 401
    end
  end

  rule 'Clear the lock and reset failed attempts upon login', on: :user_login_success do
    user = params[:user]
    if user.locked_at.present? or user.failed_attempts
      user.locked_at = nil
      user.failed_attempts = 0
      user.save
    end
  end

end
