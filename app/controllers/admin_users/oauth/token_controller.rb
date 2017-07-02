class AdminUsers::Oauth::TokenController < Opro::Oauth::TokenController

  def create
    super()

    # Setting access tokens in cookies, will be removed at the time of signing out
    if @auth_grant
      params[:request] = request
      params[:application] = 'admin_panel'
      User::Track::Login.(@auth_grant.user, params)
      cookies["access_token"] = { :value => @auth_grant.access_token, :httponly => true }
      cookies["refresh_token"] = { :value => @auth_grant.refresh_token, :httponly => true }
    end
  end
end