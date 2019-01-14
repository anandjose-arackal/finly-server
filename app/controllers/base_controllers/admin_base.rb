class BaseControllers::AdminBase < ApplicationController
  before_action -> {finly_authorize! :admin}

  def verify_authentication
    true
  end
end