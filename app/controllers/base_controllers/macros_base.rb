class BaseControllers::MacrosBase < ApplicationController

  protect_from_forgery with: :null_session
  before_action { authorize_ip(Rails.application.config_for(:finly_macros)['ip_address']) }

  http_basic_authenticate_with :name => Rails.application.config_for(:finly_macros)["inbound"]["username"],
                               :password => Rails.application.config_for(:finly_macros)["inbound"]["password"]

  before_action { validate_request }

  def authentication_scope
    :macros
  end

  def validate_request
    head 422 unless params[:macro_id].present?
  end

  def current_user
    current_macro.user
  end

  def current_macro
    Macro.find_by macro_id: params[:macro_id]
  end

  def skip_finly_authorize?
    true
  end

end