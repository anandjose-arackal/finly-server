class BaseControllers::PublicBase < ApplicationController
  def verify_authentication
    true
  end
end