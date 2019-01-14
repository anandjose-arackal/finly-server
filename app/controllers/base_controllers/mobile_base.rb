class BaseControllers::MobileBase < ApplicationController
  before_action -> {finly_authorize! :mobile}

  def verify_authentication
    true
  end
end