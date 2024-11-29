class Oauth::TokenController < Doorkeeper::TokensController
  include ActionController::Cookies
  include ActionController::Helpers
  include SessionsHelper
  include AccessibilityCheckHelper
  include ApplicationHelper
  include Helpers::UserSessionsHelper

  # around_action :save_request_impression
  around_action :set_non_tenant
  before_action :load_global_variables
  def set_non_tenant
    ActsAsTenant.without_tenant_if_not_set do
      yield
    end
  end

  def authorize_response
    ActsAsTenant.without_tenant_if_not_set do
      super
    end
  end

  def create
    return unless pre_process
    decode_params
    response = authorize_response
    headers.merge! response.headers
    self.status = response.status

    if self.status == 200
      @auth_grant = response
      @token = response.token
      @token.update_columns(authentication_type: "sso")
      @user = current_user(response&.token)
      params[:user] = @user
      params[:response] = response

      response_message = {message: params[:message]}

      #Session block for inactive users
      if User.where(id: @user.id)&.active == false
        error_message = "Invalid request"
        error_message = response_message[:message] if response_message.is_a?(Hash) and response_message[:message].present?
        json_string = {
            error: "invalid_grant",
            error_description: error_message
        }
        render json: json_string.to_json, status: 401
        return
      end

      if create_user_sessions && response_message[:message].blank?
        response_message = on_session_create
        if response_message == true or (response_message.is_a?(Hash) and response_message[:success])
          on_create_success(response)
          return
        end
      end

      error_message = "Invalid request"
      error_message = response_message[:message] if response_message.is_a?(Hash) and response_message[:message].present?
      json_string = {
          error: "invalid_grant",
          error_description: error_message
      }
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

  def revoke
    if authorized? and token&.accessible?
      token.revoke
      token.update(status_id: UserSessionStatus.id_for(:revoked))
      UserSession.find_by(access_token_id: token.id)&.update(status_id: UserSessionStatus.id_for(:revoked))
    end
    render json: {success: true}, status: 200
  end

  protected

  def check_user_active

  end

  def verify_company_status(user)
    company = user&.company rescue nil 

    if company.present?
      case company.status_id
      when CompanyStatus.id_for(:partial_block)
        if @user.admin? || @user.manager? || @user.finance_manager?
          json_string = {error: "invalid_grant", error_description: "Your company account has been disabled due to billing issue. Please contact Finly Team to have this resolved"}
          render json: json_string.to_json, status: 401
          return false
        end
      when CompanyStatus.id_for(:deactivated)
        if @user.admin? || @user.manager? || @user.finance_manager?
          json_string = {error: "invalid_grant", error_description: "Your company account has been disabled due to billing issue. Please contact Finly Team to have this resolved"}
          render json: json_string.to_json, status: 401
          return false
        else
          json_string = {error: "invalid_grant", error_description: "Your account has been disabled. Please contact your admin to login"}
          render json: json_string.to_json, status: 401
          return false
        end
        # when CompanyStatus.id_for(:active),   CompanyStatus.id_for(:hidden)
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
    params[:application] = "web"
    # self.response.set_cookie 'access_token', {:value => response.token.token, :httponly => true}
    # self.response.set_cookie 'refresh_token', {:value => response.token.refresh_token, :httponly => true}
    cookies["access_token"] = {value: @token.token, httponly: true, expires: 15.days.from_now}
    cookies["refresh_token"] = {value: @token.refresh_token, httponly: true, expires: 15.days.from_now}

    # render json: {}, status: 200
    render_json "oauth/token/create.json.jbuilder", response.status
  end

  def render_json(file_path, response_status)
    binding_params = {user: @user, auth_grant: @auth_grant, token: @token}
    view = ActionView::Base.new(ActionController::Base.view_paths, binding_params)
    render json: JSON.parse(view.render(file: file_path)), status: response_status
  end

  def set_grant_type
    params[:grant_type] = "password"
  end

  def set_scope
    scopes = self.auth_scope
    scopes = [scopes] unless scopes&.is_a?(Array)
    params[:scope] = scopes&.join(" ")
  end

  def auth_scope
    # JUGAARD AS IOS IS CURRENTLY USING THIS ENDPOINT TO GENERATE THE TOKENS
    return :mobile if params[:client_id] == "9b342c6060cc1867b371325a469e17e4"

    # JUGAAD END
    :web
  end

  def current_user(doorkeeper_token)
    if doorkeeper_token.present? && doorkeeper_token&.resource_owner_id&.present?
      scopes = doorkeeper_token[:scopes]
      if scopes.include?("web") || scopes.include?("mobile") || scopes.include?("chrome") || scopes.include?("api") || scopes.include?("admin_bypass") || scopes.include?("streamsets")
        @curr_user ||= ActsAsTenant.without_tenant_if_not_set do
          User.find_by(id: doorkeeper_token[:resource_owner_id])
        end
        ActsAsTenant.current_tenant = @curr_user&.company
        @curr_user
      elsif scopes.include?("admin")
        @curr_user ||= AdminUser.find_by(id: doorkeeper_token[:resource_owner_id])
      elsif scopes.include?("darwinbox")
        @curr_user ||= ActsAsTenant.without_tenant_if_not_set do
          User.find_by(id: doorkeeper_token[:resource_owner_id])
        end
        ActsAsTenant.current_tenant = @curr_user&.company
        @curr_user
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
    RequestStoreUtil.set_request_params params
  end

  def create_user_sessions
    sessions_result = UserSessions::Create.(:authorized, params)
    sessions_result.success? and sessions_result.session.status_id == UserSessionStatus.id_for(:authorized)
  end

  def on_session_create
    result = Gatekeeper::Event.(:after_session_create, params)
    if result.success?
      @user.otp_verified = !result.require_otp if @user.otp_verified
      @user.otp_verified = false if @user.otp_verified and @user.associated_group_users.where.not(otp_verified: true).present?
      
      unless @user.expired?
        User.where(id: @user.id).update_all(last_activity_at: DateTime.now)
      end

      return {success: true}
    else
      invalidate_session UserSessionStatus.id_for(:failed), (result.message || result.rule.description)
      return {success: false, message: result.response_message}
    end
  end

  def decode_params
    return if params[:password].blank?
    params[:password] = Base64.decode64(params[:password])
  end
end
