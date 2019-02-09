class BaseControllers::MobileBase < ApplicationController
  def authentication_scope
    :mobile
  end
end
