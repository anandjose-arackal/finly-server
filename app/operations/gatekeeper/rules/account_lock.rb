Gatekeeper::Checker.new 'AccountLock' do

  LOCKING_PERIOD ||= 30.minutes

  section 'on authorization' do

    premise :user_login_invalid_password do
      rule 'More than 5 failed attempts should lock the account' do
        user = params[:user]
        auth_failure = user.user_auth_failures.build locked: false
        if user.user_auth_failures.within_time(Time.now - LOCKING_PERIOD).size >= 4 && !user.locked_at.present?
          user.update(locked_at: DateTime.now)
          auth_failure.locked = true

          message "#{user.id} - #{user.email} > Too many failed password attempts. Locking the account"
          response_code 401
          level 5
          fail
        end
        auth_failure.save
      end
    end

    premise :user_login_attempt do
      rule 'Do not allow locked accounts to login' do
        user = params[:user]
        if user.locked_at.present? && (Time.now - user.locked_at) < LOCKING_PERIOD
          # user.user_auth_failures.create locked: true
          message "#{user.id} - #{user.email} > Account has been temporarily locked"
          level 5
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
          user.save
        end
      end
    end

  end

  section 'Browsers' do
    before do
      skip unless RequestStoreUtil.current_session&.web?
      skip unless RequestStoreUtil.current_user.access_locked?
    end

    premise :on_authenticated_request do
      rule 'Do not allow access to locked accounts' do
        message 'User Account is locked'
        session_status_id UserSessionStatus.id_for(:blocked)
        level 5
        response_code 401
        fail
      end
    end
  end

end