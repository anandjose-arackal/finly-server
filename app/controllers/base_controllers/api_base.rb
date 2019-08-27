class BaseControllers::ApiBase < ApplicationController
  protect_from_forgery with: :null_session

  def authentication_scope
    :api
  end
end
