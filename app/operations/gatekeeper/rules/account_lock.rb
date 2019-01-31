class Gatekeeper::Rules::AccountLock < Gatekeeper::Rules::BaseRule

  index Gatekeeper::Master

  rule 'More than 5 failed attempts should lock the account', on: :user_login_failed do |params|
    response_code 401
    # user = params[:user]
    # if user.failed_attempts >= 5
    #   user.update(locked_at: DateTime.now)
    #   respond_code 401
    # else
    #
    # end
  end
  
  rule 'Only whitewhiteled', on: [:before_auth_action, :after_auth] do |params|

  end

  rule 'Only whitewhiteled', on: [:before_auth_action] do |params|

  end

  rule 'Only whitewhiteled', on: [:before_auth_action, :after_auth] do |params|

  end


end