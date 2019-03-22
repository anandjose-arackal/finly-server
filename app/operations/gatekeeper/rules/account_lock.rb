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
          fail
        end
        user.save
      end
    end

    premise :user_login_attempt do
      rule 'Do not allow locked accounts to login' do
        user = params[:user]
        if user.locked_at.present? && (Time.now - user.locked_at) < LOCKING_PERIOD
          message 'Account has been temporarily locked. Please try after sometime'
          response_code 401
          fail
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

  section 'Browsers' do
    before do
      skip unless RequestStoreUtil.current_session&.client_type == 'UserDeviceBrowser'
      skip unless RequestStoreUtil.current_user.locked?
    end

    premise :on_authenticated_request do
      rule 'Do not allow access to locked accounts' do
        message 'User Account is locked'
        session_status_id UserSessionStatus.id_for(:blocked)
        response_code 401
        fail
      end
    end
  end

end