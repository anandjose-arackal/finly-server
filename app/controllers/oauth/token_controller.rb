class Oauth::TokenController < Doorkeeper::TokensController
  include ActionController::Cookies, ActionController::Helpers,
          SessionsHelper, AccessibilityCheckHelper, ApplicationHelper

  def create
    unless pre_process
      return
    end

    response = authorize_response
    headers.merge! response.headers
    self.status = response.status

    if self.status == 200
      @auth_grant = response
      @token = response.token
      @user = User.find_by(id: response.token.resource_owner_id)
      User::Track::Login.(@user, params)

      on_create_success(response)
    else
      self.response_body = response.body.to_json
    end
  rescue Doorkeeper::Errors::DoorkeeperError => e
    handle_token_exception e
  end

  protected
  def pre_process
    set_grant_type
  end

  def on_create_success(response)
    params[:request] = request
    params[:application] = 'web'
    # self.response.set_cookie 'access_token', {:value => response.token.token, :httponly => true}
    # self.response.set_cookie 'refresh_token', {:value => response.token.refresh_token, :httponly => true}
    cookies["access_token"] = {:value => @token.token, :httponly => true}
    cookies["refresh_token"] = {:value => @token.refresh_token, :httponly => true}

    # render json: {}, status: 200
    render_json 'oauth/token/create.json.jbuilder', response.status
  end

  def render_json(file_path, response_status)
    binding_params = {user: @user, auth_grant: @auth_grant, token: @token}
    view = ActionView::Base.new(ActionController::Base.view_paths, binding_params)
    render json: JSON.parse(view.render(file: file_path)), status: response_status
  end

  def set_grant_type
    ### todo TEMP WORKAROUND - MAKE ALL CLIENTS SEND USERNAME AND REMOVE THIS JUGAAD
    if params.dig(:email).present? and params.dig(:username).blank?
      params[:username] = params[:email]
    end
    ########################
    params[:grant_type] = 'password'
  end

end