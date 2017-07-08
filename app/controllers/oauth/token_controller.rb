class Oauth::TokenController < Doorkeeper::TokensController

  def create
    response = authorize_response
    headers.merge! response.headers
    self.response_body = response.body.to_json
    self.status = response.status

    # if @auth_grant
    @auth_grant = response
    @user = User.find_by(id: response.token.resource_owner_id)
    params[:request] = request
    params[:application] = 'web'
    User::Track::Login.(@user, params)
    # cookies['access_token'] = {:value => response.token.token, :httponly => true}
    # cookies['refresh_token'] = {:value => response.token.refresh_token, :httponly => true}
      # end
  # rescue Errors::DoorkeeperError => e
  #   handle_token_exception e
  end

end