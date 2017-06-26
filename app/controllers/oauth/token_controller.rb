class Oauth::TokenController < Opro::Oauth::TokenController
  def create
    super()
    if @auth_grant
      cookies["access_token"] = { :value => @auth_grant.access_token, :httponly => true }
      cookies["refresh_token"] = { :value => @auth_grant.refresh_token, :httponly => true }
    end
  end
end