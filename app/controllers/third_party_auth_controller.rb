class ThirdPartyAuthController < ApplicationController

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
