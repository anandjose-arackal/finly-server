class BaseControllers::StreamsetsBase < ApplicationController

  protect_from_forgery with: :null_session
  before_action { authorize_ip(Rails.application.config_for(:integrations)["whitelisted_ip_addresses"]) }

  http_basic_authenticate_with :name => Rails.application.config_for(:integrations)["username"],
                               :password => Rails.application.config_for(:integrations)["password"]
  def authentication_scope
    :streamsets
  end

  def current_user
  	User.find_by id: params[:user_id], company_id: params[:company_id]
  end

  def skip_finly_authorize?
  	true
  end

end
