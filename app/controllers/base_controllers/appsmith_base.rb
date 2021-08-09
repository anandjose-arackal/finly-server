class BaseControllers::AppsmithBase < ApplicationController

  layout 'trailblazers'

  protect_from_forgery with: :null_session
  before_action { authorize_ip(Rails.application.config_for(:appsmith)['ip_address']) }

  http_basic_authenticate_with :name => Rails.application.config_for(:appsmith)["username"],
                               :password => Rails.application.config_for(:appsmith)["password"]

  before_action { validate_request }

  around_action :set_non_tenant

  def set_non_tenant
    ActsAsTenant.without_tenant do
      yield
    end
  end

  def validate_request
    head 401 unless current_user.present?
  end

  def authentication_scope
    :appsmith
  end

  def current_user
    AdminUser.find_by(email: params[:email])
  end

  def skip_finly_authorize?
    true
  end

end
