class ThirdPartyAuthController < BaseControllers::WebBase



  def quickbooks
    # action will save the authentication object to the db based on the callback
    @result = Integrations::Quickbooks::Authentication::Create.(current_user, {omniauth: request.env['omniauth.auth']})
    respond
  end

  def tally

  end

end
