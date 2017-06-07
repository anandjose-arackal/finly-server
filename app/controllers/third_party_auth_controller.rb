class ThirdPartyAuthController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def quickbooks
    # action will save the authentication object to the db based on the callback
    @result = Integrations::Quickbooks::Authentication::Create.(current_user, {omniauth: env['omniauth.auth']})
    if @result.success?
      flash[:success] = @result.messages[:success]
    else
      flash[:failure] = @result.messages[:error]
    end
  end

  def tally

  end

end
