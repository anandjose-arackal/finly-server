class BaseControllers::WebBase < ApplicationController

  before_action :set_client_version

  def set_client_version
    version = WebClient.first&.version
    response.set_header 'Version', version if version.present?
  end

  def authentication_scope
    :web
  end

end
