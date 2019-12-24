Gatekeeper::Checker.new 'AccountLock' do

  before do
    skip if RequestStoreUtil.current_session.admin_user_id.present?
  end

  section 'on authentication' do

    premise :after_session_create do
      rule 'Do not allow deactivated or blocked company accounts to login' do
        user = RequestStoreUtil.current_user
        if user.company.blocked?
          message "#{user.id} - #{user.email} > Company account has been blocked"
          response_message "Your account has been deactivated. Kindly contact your company admin"
          level 3
          response_code 401
          fail
        end
      end

      rule 'Do not allow partially blocked company accounts to login if the user is admin/creditor' do
        user = RequestStoreUtil.current_user
        if user.company.partial_blocked? and
            (user.admin? or user.has_policy_role?(UserRole.id_for(:creditor)) or
                user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor)) or
                user.has_policy_role?(UserRole.id_for(:finance_manager)))
          # user.user_auth_failures.create locked: true
          message "#{user.id} - #{user.email} > Company account has been blocked"
          response_message "Your account has been deactivated. Kindly contact your company admin"
          level 3
          response_code 401
          fail
        end
      end
    end

  end

  section 'on authenticated request' do
    premise :on_authenticated_request do
      rule 'Do not allow deactivated or blocked company accounts to access the system' do
        user = RequestStoreUtil.current_user
        if user.company.blocked?
          message "#{user.id} - #{user.email} > Company account has been blocked"
          response_message "Your account has been deactivated. Kindly contact your company admin"
          level 3
          response_code 401
          fail
        end
      end

      rule 'Do not allow partially blocked company accounts to access the system if the user is admin/creditor' do
        user = RequestStoreUtil.current_user
        if user.company.partial_blocked? and
            (user.admin? or user.has_policy_role?(UserRole.id_for(:creditor)) or
                user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor)) or
                user.has_policy_role?(UserRole.id_for(:finance_manager)))
          # user.user_auth_failures.create locked: true
          message "#{user.id} - #{user.email} > Company account has been blocked"
          response_message "Your account has been deactivated. Kindly contact your company admin"
          level 3
          response_code 401
          fail
        end
      end
    end
  end

end