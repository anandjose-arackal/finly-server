class BaseControllers::WebBase < ApplicationController
  before_action -> {finly_authorize! :web}

  def verify_authentication
    true
  end
end