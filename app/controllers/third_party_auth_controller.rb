class ThirdPartyAuthController < ApplicationController


  before_action -> { doorkeeper_authorize! :web}

  def quickbooks
    # action will save the authentication object to the db based on the callback
    @result = Integrations::Quickbooks::Authentication::Create.(current_user, {omniauth: env['omniauth.auth']})
    respond
  end

  def tally

  end

end
