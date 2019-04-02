class Oauth::TokenController < Doorkeeper::TokensController
  include ActionController::Cookies
  include ActionController::Helpers
  include SessionsHelper
  include AccessibilityCheckHelper
  include ApplicationHelper
  include Helpers::UserSessionsHelper
  include Helpers::RequestImpressionHelper

  around_action :save_request_impression
  before_action :load_global_variables

  def create
    return unless pre_process

    response = authorize_response
    headers.merge! response.headers
    self.status = response.status

    if self.status == 200
      @auth_grant = response
      @token = response.token
      @user = current_user(response&.token)
      params[:user] = @user
      params[:response] = response
      # Jugaad as frontend is not developed for capturing device_type
      params[:temporary_client_type] = 'UserDeviceBrowser'
      # Jugaad end as frontend is not developed for capturing device_type
      sessions_result = create_user_sessions
      if sessions_result.success? and sessions_result.session.status_id == UserSessionStatus.id_for(:authorized)
        result = Gatekeeper::Event.(:after_session_create, params)
        if result.success?
          @user.otp_verified = !result.require_otp if @user.otp_verified

          unless @user.expired?
            @user.update(last_activity_at: DateTime.now)
          end

          on_create_success(response)
          return
        else
          invalidate_session UserSessionStatus.id_for(:failed), (result.message || result.rule.description)
        end
      end

      json_string = {error: 'invalid_grant', error_description: 'The email / mobile or password you entered is incorrect'}
      render json: json_string.to_json, status: 401

      # if verify_company_status(@user)
      #   User::Track::Login.(@user, params)
      # end
    else
      self.response_body = response.body.to_json
    end
  rescue Doorkeeper::Errors::DoorkeeperError => e
    handle_token_exception e
  end

  protected

  def verify_company_status(user)
    company = user&.company rescue nil

    if company.present?
      case company.status_id
      when CompanyStatus.id_for(:partial_block)
        if @user.admin? || @user.manager? || @user.finance_manager?
          json_string = {error: 'invalid_grant', error_description: 'Your company account has been disabled due to billing issue. Please contact Finly Team to have this resolved'}
          render json: json_string.to_json, status: 401
          return false
        end
      when CompanyStatus.id_for(:deactivated)
        if @user.admin? || @user.manager? || @user.finance_manager?
          json_string = {error: 'invalid_grant', error_description: 'Your company account has been disabled due to billing issue. Please contact Finly Team to have this resolved'}
          render json: json_string.to_json, status: 401
          return false
        else
          json_string = {error: 'invalid_grant', error_description: 'Your account has been disabled. Please contact your admin to login'}
          render json: json_string.to_json, status: 401
          return false
        end
        # when CompanyStatus.id_for(:active), CompanyStatus.id_for(:hidden)
        # Nothing to do
      end
    end
    true
  end

  def pre_process
    ### todo TEMP WORKAROUND - MAKE ALL CLIENTS SEND USERNAME AND REMOVE THIS JUGAAD
    params[:username] = params[:email] if params.dig(:email).present? && params.dig(:username).blank?
    ########################

    set_grant_type
    set_scope
  end

  def on_create_success(response)
    params[:request] = request
    params[:application] = 'web'
    # self.response.set_cookie 'access_token', {:value => response.token.token, :httponly => true}
    # self.response.set_cookie 'refresh_token', {:value => response.token.refresh_token, :httponly => true}
    cookies['access_token'] = {value: @token.token, httponly: true, expires: 15.days.from_now}
    cookies['refresh_token'] = {value: @token.refresh_token, httponly: true, expires: 15.days.from_now}

    # render json: {}, status: 200
    render_json 'oauth/token/create.json.jbuilder', response.status
  end

  def render_json(file_path, response_status)
    binding_params = {user: @user, auth_grant: @auth_grant, token: @token}
    view = ActionView::Base.new(ActionController::Base.view_paths, binding_params)
    render json: JSON.parse(view.render(file: file_path)), status: response_status
  end

  def set_grant_type
    params[:grant_type] = 'password'
  end

  def set_scope
    scopes = self.auth_scope
    scopes = [scopes] unless scopes&.is_a?(Array)
    params[:scope] = scopes&.join(' ')
  end

  def auth_scope
    # JUGAARD AS IOS IS CURRENTLY USING THIS ENDPOINT TO GENERATE THE TOKENS
    return :mobile if params[:client_id] == '9b342c6060cc1867b371325a469e17e4'

    # JUGAAD END
    :web
  end

  def current_user(doorkeeper_token)
    if doorkeeper_token.present? && doorkeeper_token&.resource_owner_id&.present?
      scopes = doorkeeper_token[:scopes]
      if scopes.include?('web') || scopes.include?('mobile') || scopes.include?('chrome') || scopes.include?('api') || scopes.include?('admin_bypass')
        @curr_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id])
      elsif scopes.include?('admin')
        @curr_user ||= AdminUser.find_by(id: doorkeeper_token[:resource_owner_id])
      elsif scopes.include?('darwinbox')
        @curr_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id])
      end
    end
  end

  def invalidate_session(status_id, reason)
    RequestStoreUtil.current_session&.update(status_id: status_id, message: reason)
    RequestStoreUtil.current_session_event&.update(status_id: status_id, message: reason)
    @token&.update(status_id: status_id, message: reason)
  end

  def load_global_variables
    RequestStoreUtil.set_current_request request
  end

  def create_user_sessions
    UserSessions::Create.(:authorized, params)
  end
end
