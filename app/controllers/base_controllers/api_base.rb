class BaseControllers::ApiBase < ApplicationController

  def authentication_scope
    :api
  end
end
