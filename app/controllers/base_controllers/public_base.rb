class BaseControllers::PublicBase < ApplicationController
  def authentication_scope
    :public
  end
end
