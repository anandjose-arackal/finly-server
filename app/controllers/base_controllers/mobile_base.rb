class BaseControllers::MobileBase < ApplicationController
  protect_from_forgery with: :null_session

  def authentication_scope
    :mobile
  end
end
