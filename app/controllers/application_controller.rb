require 'require_all'

# Dir[File.expand_path "#{Rails.root}/app/operations/event/**/*.rb"].each { |f| require(f) }
# Dir[File.expand_path "#{Rails.root}/app/operations/expense/card/**/*.rb"].each { |f| require(f) }
class ApplicationController < ActionController::Base
  include SessionsHelper, AccessibilityCheckHelper, ApplicationHelper, Helpers::UserSessionsHelper, BankPaymentRequestsHelper
  # include AbstractController::Callbacks
  # include ActionController::Head
  include Doorkeeper::Rails::Helpers
  include Helpers::RequestImpressionHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :null_session
  # before_action :set_paper_trail_whodunnit

  around_action :save_request_impression
  before_action :finly_authorize!

  # before_action :load_global_variables
  before_action :after_finly_authorize
  # before_action :set_raven_context

  before_action :initialize_query_logger

  before_action :init_elastic_apm

  before_action :store_location

  after_action :set_queries_counter
  # after_action :track_request

  # handling exceptions and other errors through redirects to 404s and 500s
  # rescue_from ActiveRecord::RecordNotFound, with: :not_found
  # rescue_from StandardError, with: :error
  # rescue_from ActionController::RoutingError, with: :not_found

  # handles 404 errors
  def not_found
    respond_to do |format|
      format.html {render file: "#{Rails.root}/public/404", layout: false, status: :not_found}
      format.xml {head :not_found}
      format.any {head :not_found}
    end
  end

  # handles 500 errors
  def error
    respond_to do |format|
      format.html {render file: "#{Rails.root}/public/500", layout: false, status: :error}
      format.xml {head :not_found}
      format.any {head :not_found}
    end
  end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get?
    if request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/password/edit" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/sign_out" &&
        !request.xhr? # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def respond_to_ajax_with_success(redirect_path = root_path, force = false)
    redirect_path = request.referrer if request.referrer && !force
    respond_to do |format|
      format.html {redirect_to redirect_path}
      format.js {redirect_to redirect_path, turbolinks: true}
      format.json {}
    end
  end

  def render_flash_message
    respond_to do |format|
      format.html do
        if request.present? && request.referrer.present?
          redirect_to request.referrer
        else
          render partial: 'shared/flash_message'
        end
      end
      format.js do
        render partial: 'shared/flash_message'
      end
      format.json {}
    end
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(AdminUser)
      'admin'
    else
      root_path
    end
  end

  def current_app
    # Check header to identify app
    header_app = request.headers['App']
    if header_app.present?
      case header_app
      when 'ap', :ap
        return :ap
      when 'ft', :ft
        return :ft
      when 'vp', :vp
        return :vp
      when 'em', :em
        return :em
      when 'fc', :fc
        return :fc
      end
    end
    # todo Referrer is jugaad as disburse is using expense management endpoints.
    path = nil
    path = URI(request.referrer).path if request.referrer.present?
    path = request.path if path.blank?
    if path.is_a?(String)
      if path.starts_with?('/admin')
        return :ap
      elsif path.starts_with?('/payments')
        return :vp
      elsif path.starts_with?('/disburse')
        return :ft
      elsif path.starts_with?('/collect')
        return :fc
      end
    end
    :em
  end

  def current_device
    path = request.path
    if path.is_a?(String)
      if path.starts_with?('/api')
        return :api
      elsif path.starts_with?('/mobile')
        return :mobile
      elsif path.starts_with?('/desktop')
        # todo desktop login
        return :desktop
      end
    end
    :web
  end

  def current_user
    if RequestStore.store[:current_user].present?
      if RequestStore.store[:current_company].present? or RequestStore.store[:current_user].class.name != 'User'
        return RequestStore.store[:current_user]
      end
    end
    @curr_user = nil
    if doorkeeper_token.present? and doorkeeper_token&.resource_owner_id&.present?
      scopes = doorkeeper_token[:scopes]
      if scopes.include?('web') or scopes.include?('mobile') or scopes.include?('chrome') or scopes.include?('api')
        @curr_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id])
      elsif scopes.include?('admin')
        @curr_user ||= AdminUser.find_by(id: doorkeeper_token[:resource_owner_id])
      end
    end
    RequestStoreUtil.set_current_user @curr_user
    if @curr_user.class.name == 'User'
      RequestStoreUtil.set_current_company @curr_user&.company
    end

    # looking for if the particular user is a delegate for someone else
    retrieve_delegate_user

    @curr_user
  end

  def current_company
    current_user
    RequestStore.store[:current_company]
  end

  protected

  def retrieve_delegate_user
    # header is going to send a 'delegate_for_user_id' attribute
    delegate_for_user_id = request.headers['Delegate-For-User-Id']
    delegated_for_user = @curr_user.delegated_for_users.find_by(id: delegate_for_user_id) if delegate_for_user_id.present?
    if delegated_for_user.present?
      RequestStore.store[:actual_current_user] = @curr_user # setting the actual current user as this guy
    end
    if delegated_for_user.present?
      @curr_user = delegated_for_user
      RequestStore.store[:current_user] = delegated_for_user
    end
  end

  def respond_success_failure
    respond response: (@result.success? ? :success : :failure)
  end

  def respond(type = nil)
    if type.present?
      if type[:response] == :success
        if @result.blank?
          messages = {}
          messages[:success] = [type[:message]] if type[:message].present?
          @result = BaseOperation::BasePresenter::SuccessPresenter.new(current_user, params, messages)
        end
        respond_to do |format|
          format.json {render 'shared/success'}
          format.html {}
        end
        return
      elsif type[:response] == :failure
        if @result.blank?
          messages = {}
          messages[:error] = [type[:message]] if type[:message].present?
          @result = BaseOperation::BasePresenter::FailurePresenter.new(current_user, params, messages)
        end
        respond_to do |format|
          format.json {render 'layouts/application'}
          format.html {}
        end
        return
      elsif type[:render].present?
        respond_to do |format|
          format.json {render type[:render]}
          format.html {}
        end
        return
      elsif type[:view].present? and type[:view] == false
        respond_to do |format|
          format.json {render 'layouts/application'}
          format.html {}
        end
        return
      end
    end
    if @result.present?
      if @result.success?
        if [Exporter, Exporter::Spreadsheet, Exporter::Pdf, Exporter::AsZip].include? @result.class
          @result.render(self)
        else
          respond_to do |format|
            format.js {}
            format.json {}
            format.html {}
            format.xls {}
          end
        end
      else
        respond_to do |format|
          format.js {render 'layouts/application'}
          format.json {render 'layouts/application'}
          format.html {}
          format.xls {}
        end
      end
    else
      respond_to do |format|
        format.js {}
        format.json {render 'layouts/application'}
        format.html {}
      end
    end
  end

  def load_global_variables
    RequestStoreUtil.set_current_request(request)
    RequestStoreUtil.set_request_params params
    RequestStoreUtil.set_current_app current_app
    RequestStoreUtil.set_current_device current_device
    RequestStoreUtil.set_current_token doorkeeper_token
  end

  def respond_failure(message = nil)
    messages = nil
    messages = [message] unless message.blank? or message.is_a?(Array)
    @result = BaseOperation::BasePresenter::FailurePresenter.new(current_user, params, {error: messages})
    respond_to do |format|
      format.json {render 'layouts/application'}
    end
  end

  # Used by API's
  def action_success
    @action_success = true
  end

  def after_sign_out_path_for(resource)
    root_url
  end

  def authorize_ip(authorized_list)
    authorized_list = [authorized_list] if authorized_list.class.name == String.name
    unless authorized_list.include?(request.remote_ip)
      head 403
    end
  end

  def whitelisted?(ip, type_id)
    WhitelistedIp.with_type(type_id).with_ip(ip).present?
  end

  def block_foreign_hosts(type_id)
    return false if whitelisted?(request.remote_ip, type_id)
    head(403)
  end

  def skip_finly_authorize?
    scopes = *authentication_scope
    scopes.delete(:public)
    scopes.blank? or self.class.get_skip_authentication_actions.include?(action_name&.to_sym)
  end

  def finly_authorize!
    scopes = *authentication_scope
    scopes.delete(:public)
    return if skip_finly_authorize?

    set_tokens_in_header

    doorkeeper_authorize! *scopes

    unless doorkeeper_token&.status_id == UserSessionStatus.id_for(:authorized)
      head 401
      return
    end

    load_global_variables

    if current_user.present?
      RequestStoreUtil.set_authorized_scopes scopes
    end

    verify_user_session(doorkeeper_token)
  end

  def verify_user_session(doorkeeper_token)
    user_session = UserSession.find_by_access_token_id(doorkeeper_token.id)
    if user_session.nil?
      if doorkeeper_token.scopes.include?('web')
        doorkeeper_token.update(status_id: UserSessionStatus.id_for(:expired), message: 'UserSession does not exist')
        head 401
        return false
      else
        # todo better handle how existing logins are associated i.e mobile, API etc
        # params[:user] = current_user
        # params[:message] = 'User Session not found'
        # params[:scope] = doorkeeper_token.scopes.to_s
        # result = UserSessions::Create.(:authorized, params)
        # unless result.success?
        #   doorkeeper_token.update(status_id: UserSessionStatus.id_for(:expired), message: 'User Session does not exist')
        #   head 401
        # end
        # user_session = result.session
        # todo temp workaround
        return true
      end
    end
    RequestStoreUtil.set_current_session user_session

    result = UserSessions::Events::Create.(current_user, params)
    RequestStoreUtil.set_current_event result.event

    unless user_session.authorized?
      head 401
      return
    end

    UserDevices::XFinlyRPProcessor.from_client(user_session.user_device&.client)

    result = Gatekeeper::Event.(:on_authenticated_request, user: current_user)
    unless result.success?
      session_status = result.session_status_id || UserSessionStatus.id_for(:blocked)
      invalidate_session session_status, result.message
      return false
    end


    return false unless last_request_at_changed?(user_session)

    user_session.update(last_request_at: DateTime.now)
    true
  end

  def last_request_at_changed?(user_session)
    return true if user_session.admin_user_id.present?

    return false unless user_session.authorized?
    ['otp/resend', 'otp/verify', 'users/password', 'notifications/unread'].each {|path| return false if request.path.include?(path)}
    return false if current_user.expired?
    return false unless current_user.otp_verified
    return false unless user_session.user_device.status_id == UserDeviceStatus.id_for(:verified)
    return false unless user_session.user_ip.status_id == UserIpStatus.id_for(:verified)
    return false unless user_session.user_agent_client.status_id == UserAgentClientStatus.id_for(:verified)

    true
  end

  def invalidate_session(status_id, reason)
    RequestStoreUtil.current_session&.update(status_id: status_id, message: reason)
    RequestStoreUtil.current_session_event&.update(status_id: status_id, message: reason)
    doorkeeper_token&.update(status_id: status_id, message: reason)
    head 401
  end

  @skip_authentication_actions = []

  def self.skip_authentication_actions(*actions)
    @skip_authentication_actions = [] if @skip_authentication_actions.nil?
    @skip_authentication_actions += actions
  end

  def self.get_skip_authentication_actions
    @skip_authentication_actions || []
  end

  def authentication_scope
    raise "IMPORTANT!! Do not extend ApplicationController. Extend one of the BaseController's available in controllers/base_controller"
  end

  @required_header_token_actions = []

  def self.required_header_token_actions
    @required_header_token_actions ||= []
  end

  def self.set_tokens_in_header(*actions)
    @required_header_token_actions = actions
  end

  def set_tokens_in_header
    if self.class.required_header_token_actions.include?(action_name)
      access_token = request.cookies['access_token']
      if access_token.present?
        request.headers['Authorization'] = "Bearer #{access_token}"
      end
    end
  end

  def initialize_query_logger
    QueryLogger.reset if ENABLE_QUERY_LOGGER
  end

  FILE_LOGGER = LogStashLogger.new(type: :file, path: 'log/logstash_query_details.log', sync: true)

  def set_queries_counter
    return unless ENABLE_QUERY_LOGGER
    return if params[:controller] == 'notifications' && params[:action] == 'unread'
    log = {
        path: request.path,
        controller: request.params[:controller],
        action: request.params[:action],
        total_query_time: QueryLogger.time,
        queries_count: QueryLogger.count,
        queries_summary: QueryLogger.summary,
        # queries: QueryLogger.queries,
        current_app: current_app,
        current_device: current_device,
        request_id: Security.generate_hmac_hex(self.object_id.to_s, DateTime.now.to_s)
    }
    user = current_user rescue nil
    if user.present?
      log[:user_id] = user&.id
      log[:user_name] = (user&.name rescue nil)
      log[:user_email] = user&.email
      log[:user_mobile_number] = user&.mobile_number
      log[:current_app] = current_app
      log[:current_device] = current_device
      log[:company_name] = (current_company&.name rescue nil)
      log[:company_id] = (current_company&.id rescue nil)
      view = (params&.dig(:view) rescue nil)
      log[:current_view] = view
    end
    FILE_LOGGER.info(log)
  end

  # def track_request
  #   user_id = current_user&.id
  #   # Track only if user is present
  #   return if user_id.blank? or request.remote_ip.blank?
  #   return unless current_user.class.name == User.name
  #   # Create new visit in background
  #   TrackerListener.enqueue request, params, current_company&.id, current_user&.id, current_device, current_app
  # end

  def init_elastic_apm
    return unless Rails.env.production?
    return unless current_user
    return unless current_user.is_a?(User)
    ElasticAPM.set_user(current_user)
    ElasticAPM.set_tag(:company_id, current_user.company_id)
    ElasticAPM.set_tag(:company_name, current_user.company_name)
    ElasticAPM.set_tag(:user_id, current_user.id)
    ElasticAPM.set_tag(:user_name, current_user.name)
    ElasticAPM.set_tag(:app, current_app)
    ElasticAPM.set_tag(:device, current_device)
    ElasticAPM.set_tag(:view, params&.dig(:view))
  end

  def after_finly_authorize
    return if skip_finly_authorize?
    result = Gatekeeper::Event.(:after_finly_authorize, params)
    unless result.success?
      invalidate_session UserSessionStatus.id_for(:revoked), result.message
      return
    end
  end

  # Used by sentry
  # def set_raven_context
  #   Raven.user_context(id: current_user&.id) # or anything else in session
  #   view = (params&.dig(:view) rescue nil)
  #   Raven.extra_context(
  #       params: params.to_unsafe_h,
  #       url: request.url,
  #       company_name: current_company&.name,
  #       company_id: current_company&.id,
  #       user_name: current_user&.name,
  #       user_id: current_user&.id,
  #       current_device: current_device,
  #       current_app: current_app,
  #       current_view: view
  #   )
  # end

end
