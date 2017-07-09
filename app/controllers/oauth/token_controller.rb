class Oauth::TokenController < Doorkeeper::TokensController

  def create
    response = authorize_response
    headers.merge! response.headers

    self.status = response.status

    # if @auth_grant
    if self.status == 200
      @auth_grant = response
      @user = User.find_by(id: response.token.resource_owner_id)
      params[:request] = request
      params[:application] = 'web'
      # cookies['access_token'] = {:value => response.token.token, :httponly => true}
      # cookies['refresh_token'] = {:value => response.token.refresh_token, :httponly => true}
      self.response.set_cookie 'access_token', {:value => response.token.token, :httponly => true}
      self.response.set_cookie 'refresh_token', {:value => response.token.refresh_token, :httponly => true}
      User::Track::Login.(@user, params)
      # render json: {}, status: 200
      render_json 'oauth/token/create.json.jbuilder', response.status
    else
      self.response_body = response.body.to_json
    end
      # end
  rescue Doorkeeper::Errors::DoorkeeperError => e
    handle_token_exception e
  end

  protected
  def render_json(file_path, response_status)
    binding_params = {user: @user, auth_grant: @auth_grant}
    view = ActionView::Base.new(ActionController::Base.view_paths, binding_params)
    render json: JSON.parse(view.render(file: file_path)), status: response_status
  end

end