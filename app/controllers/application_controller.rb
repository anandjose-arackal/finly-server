require 'require_all'

# Dir[File.expand_path "#{Rails.root}/lib/operations/event/**/*.rb"].each{|f| require_relative(f)}
# require_all "#{Rails.root}/lib/operations"
# require_all "#{Rails.root}/lib/operations/event"
class ApplicationController < ActionController::Base
  include SessionsHelper, AccessibilityCheckHelper, ApplicationHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit

  protect_from_forgery with: :exception
  before_filter :set_paper_trail_whodunnit

  # to add custom parameters to the user hash being taken as input
  before_action :configure_permitted_parameters if :devise_controller?

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

  # def after_sign_in_path_for(resource)
  #   session[:previous_url] || root_path
  # end

  protected
  def respond(type=nil)
    if type.present?
      if type[:response] == :success
        @result = BaseOperation::BasePresenter::SuccessPresenter.new(current_user, params, {success: [type[:message]]})
        respond_to do |format|
          format.json { render 'shared/success' }
        end
        return
      elsif type[:response] == :failure
        @result = BaseOperation::BasePresenter::FailurePresenter.new(current_user, params, {error: [type[:message]]})
        respond_to do |format|
          format.json { render 'layouts/application' }
        end
        return
      elsif type[:render].present?
        respond_to do |format|
          format.json { render type[:render] }
        end
        return
      elsif type[:view].present? and type[:view] == false
        respond_to do |format|
          format.json { render 'layouts/application' }
        end
        return
      end
    end
    if @result.present? and @result.success?
      respond_to do |format|
        format.json {}
      end
    else
      respond_to do |format|
        format.json { render 'layouts/application' }
      end
    end
  end

  def respond_failure(message=nil)
    messages = [message] unless message.is_a?(Array)
    @result = BaseOperation::BasePresenter::FailurePresenter.new(current_user, params, {errors: messages})
    respond_to do |format|
      format.json { render 'layouts/application' }
    end
  end

  # Used by API's
  def action_success
    @action_success = true
  end

  def configure_permitted_parameters
    # devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar, :dob, :address, :pin, :number, :company_name, :admin, :manager_id, :user_type_id, :company_id])
    # devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def after_sign_in_path(resource)
    # puts "REROUTING AFTER LOGIN AND CURRENT USER IS TYPE: " + current_user.user_type_id
    if resource.is_a?(User)
      if current_user.admin?
        admin_company_expenses_path
      elsif current_user.manager?
        admin_expenses_path
      else
        user_expenses_path(current_user)
      end
    end
  end

  def after_sign_out_path_for(resource)
    root_url
  end
end
