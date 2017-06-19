class Oauth::TokenController < Opro::Oauth::TokenController
  def create
    super()
    if @auth_grant
      params[:request] = request
      params[:application] = 'web'
      User::Track::Login.(@auth_grant.user, params)
      cookies["access_token"] = { :value => @auth_grant.access_token, :httponly => true }
      cookies["refresh_token"] = { :value => @auth_grant.refresh_token, :httponly => true }
    end
  end
end