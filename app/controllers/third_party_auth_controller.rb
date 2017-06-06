class ThirdPartyAuthController < ApplicationController

  def quickbooks
    # this action will decide which authentication to use and appropriately
    # will probably have to be moved to an operation depending on the type of integration - i.e. quickbooks or tally
    auth = env['omniauth.auth']
    user_auth = current_user.authentications.where(provider: auth.provider).first_or_initialize
    user_auth.uid = auth.uid
    user_auth.token = auth.credentials.token
    user_auth.secret = auth.credentials.secret
    user_auth.save

  end

  def tally

  end

  # def testing
  #
  # end
end
