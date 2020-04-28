class WebClientsController < BaseControllers::PublicBase
  layout 'trailblazers'

  before_action :http_authenticate

  def http_authenticate
    web_client = Rails.application.config_for(:web_client).with_indifferent_access
    return head(401) unless web_client.present?
    return head(401) unless authorize_ip(web_client[:authorized_ip])

    authenticate_or_request_with_http_basic do |username, password|
      username == web_client[:username] && password == web_client[:password]
    end
  end

  def create
    endpoint WebClients::Create
  end
end
