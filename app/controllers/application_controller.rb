require 'require_all'

# Dir[File.expand_path "#{Rails.root}/app/operations/event/**/*.rb"].each { |f| require(f) }
# Dir[File.expand_path "#{Rails.root}/app/operations/expense/card/**/*.rb"].each { |f| require(f) }
class ApplicationController < ActionController::Base
  include SessionsHelper, AccessibilityCheckHelper, ApplicationHelper
  # include AbstractController::Callbacks
  # include ActionController::Head
  include Doorkeeper::Rails::Helpers
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  # protect_from_forgery with: :exception
  before_filter :set_paper_trail_whodunnit

  before_action :load_global_variables

  before_filter :store_location

  # handling exceptions and other errors through redirects to 404s and 500s
  # rescue_from ActiveRecord::RecordNotFound, with: :not_found
  # rescue_from StandardError, with: :error
  # rescue_from ActionController::RoutingError, with: :not_found

  # handles 404 errors
  def not_found
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404", layout: false, status: :not_found }
      format.xml { head :not_found }
      format.any { head :not_found }
    end
  end

  # handles 500 errors
  def error
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/500", layout: false, status: :error }
      format.xml { head :not_found }
      format.any { head :not_found }
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
      format.html { redirect_to redirect_path }
      format.js { redirect_to redirect_path, turbolinks: true }
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

  protected
  def respond(type=nil)
    if type.present?
      if type[:response] == :success
        if @result.blank?
          messages = {}
          messages[:success] = [type[:message]] if type[:message].present?
          @result = BaseOperation::BasePresenter::SuccessPresenter.new(current_user, params, messages)
        end
        respond_to do |format|
          format.json { render 'shared/success' }
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
          format.json { render 'layouts/application' }
          format.html {}
        end
        return
      elsif type[:render].present?
        respond_to do |format|
          format.json { render type[:render] }
          format.html {}
        end
        return
      elsif type[:view].present? and type[:view] == false
        respond_to do |format|
          format.json { render 'layouts/application' }
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
          end
        end
      else
        respond_to do |format|
          format.js { render 'layouts/application' }
          format.json { render 'layouts/application' }
          format.html {}
        end
      end
    else
      respond_to do |format|
        format.js {}
        format.json { render 'layouts/application' }
        format.html {}
      end
    end
  end

  def load_global_variables
    RequestStore.store[:request] = request
    RequestStore.store[:params] = params
    RequestStore.store[:current_app] = current_app
    RequestStore.store[:current_devise] = current_devise
  end

  def current_app
    # Check header to identify app
    header_app = request.headers['App']
    if header_app.present?
      case header_app
        when 'ap', :ap
          return :ap
        when 'fm', :fm
          return :fm
        when 'vp', :vp
          return :vp
        when 'em', :em
          return :em
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
      end
    end
    :em
  end

  def current_devise
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

  def respond_failure(message=nil)
    messages = nil
    messages = [message] unless message.blank? or message.is_a?(Array)
    @result = BaseOperation::BasePresenter::FailurePresenter.new(current_user, params, {error: messages})
    respond_to do |format|
      format.json { render 'layouts/application' }
    end
  end

  # Used by API's
  def action_success
    @action_success = true
  end

  def after_sign_out_path_for(resource)
    root_url
  end

  def whitelisted?(ip, type_id)
    return true if WhitelistedIp.with_type(type_id).with_ip(ip).present?
    false
  end

  def block_foreign_hosts(type_id)
    return false if whitelisted?(request.remote_ip, type_id)
    head(403)
  end

  def finly_authorize!(*scopes)
    doorkeeper_authorize! *scopes
    if current_user.present?
      RequestStore.store[:authorized_scopes] = scopes
    end
  end

  def current_user
    if RequestStore.store[:current_user].present?
      if RequestStore.store[:current_company].present? or RequestStore.store[:current_user].class.name != 'User'
        return RequestStore.store[:current_user]
      end
    end
    if doorkeeper_token.present? and doorkeeper_token&.resource_owner_id&.present?
      scopes = doorkeeper_token[:scopes]
      if scopes.include?('admin')
        @current_user ||= AdminUser.find_by(id: doorkeeper_token[:resource_owner_id])
      elsif scopes.include?('web') or scopes.include?('mobile') or scopes.include?('chrome')or scopes.include?('api')
        @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id])
      end
    end
    RequestStore.store[:current_user] = @current_user
    if @current_user.class.name == 'User'
      RequestStore.store[:current_company] = @current_user&.company
    end
    @current_user
  end

  def current_company
    current_user
    RequestStore.store[:current_company]
  end

  def set_tokens_in_header
    access_token = request.cookies['access_token']
    if access_token.present?
      request.headers['Authorization'] = "Bearer #{access_token}"
    end
  end

  def set_tokens_in_header_admin
    access_token = request.cookies['access_token_admin']
    if access_token.present?
      request.headers['Authorization'] = "Bearer #{access_token}"
    end
  end

end
