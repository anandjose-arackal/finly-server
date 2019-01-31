class Gatekeeper::Rules::AccountLock < Gatekeeper::Rules::BaseRule

  index Gatekeeper::Master

  rule 'More than 5 failed attempts should lock the account', on: :user_login_failed do
    user = params[:user]
    if user.failed_attempts < 5
      response_code 200
    else
      response_code 401
    end
  end
  
  rule 'Only whitewhiteled', on: [:before_auth_action, :after_auth] do

  end

  rule 'Only whitewhiteled', on: [:before_auth_action] do

  end

  rule 'Only whitewhiteled', on: [:before_auth_action, :after_auth] do

  end


end