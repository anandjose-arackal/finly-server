Gatekeeper::Checker.new 'AccountLock' do

  LOCKING_PERIOD ||= 30.minutes

  section 'on authorization' do

    premise :user_login_invalid_username do
      rule 'If invalid username is entered more than 20 times, throttle the IP' do
        # TODO: throttle the IP
      end
    end

    premise :user_login_invalid_password do
      rule 'More than 5 failed attempts should lock the account' do
        user = params[:user]
        user.failed_attempts ||= 0
        user.failed_attempts += 1
        if user.failed_attempts >= 5 && !user.locked_at.present?
          user.locked_at = DateTime.now
          message 'Too many failed password attempts. Locking the account'
          response_code 401
        end
        user.save
      end
    end

    premise :user_login_attempt do
      rule 'Do not allow locked accounts to login' do
        user = params[:user]
        if user.locked_at.present? && (Time.now - user.locked_at) < LOCKING_PERIOD
          add_message :error, 'Account has been temporarily locked. Please try after sometime'
          response_code 401
        end
      end
    end

    premise :user_login_success do
      rule 'Clear the lock and reset failed attempts upon login' do
        user = params[:user]
        if user.locked_at.present? || user.failed_attempts
          user.locked_at = nil
          user.failed_attempts = 0
          user.save
        end
      end
    end

  end

end