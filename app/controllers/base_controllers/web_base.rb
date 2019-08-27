class BaseControllers::WebBase < ApplicationController

  def authentication_scope
    :web
  end

end
