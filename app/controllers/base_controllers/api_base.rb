class BaseControllers::ApiBase < ApplicationController
  before_action -> {finly_authorize! :api}

  def verify_authentication
    true
  end
end