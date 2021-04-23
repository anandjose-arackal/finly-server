class BaseControllers::MacrosBase < ApplicationController
  layout 'trailblazers'

  protect_from_forgery with: :null_session
  before_action {authorize_ip(Rails.application.config_for(:finly_macros)['inbound']['ip_address'])}

  http_basic_authenticate_with :name => Rails.application.config_for(:finly_macros)['inbound']["username"],
                               :password => Rails.application.config_for(:finly_macros)['inbound']["password"]

  before_action {validate_request}

  def authentication_scope
    :macros
  end

  def validate_request
    head 422 unless params[:macro_id].present?
  end

  def current_user
    user = current_macro&.user
    ActsAsTenant.current_tenant = user&.company
    user
  end

  def current_macro
    ActsAsTenant.without_tenant do
      Macro.find_by id: params[:macro_id]
    end
  end

  def skip_finly_authorize?
    true
  end

end