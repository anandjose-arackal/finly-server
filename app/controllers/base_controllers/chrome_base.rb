class BaseControllers::ChromeBase < ApplicationController
  before_action -> {finly_authorize! :chrome}

  def verify_authentication
    true
  end
end