class BaseControllers::ChromeBase < ApplicationController
  def authentication_scope
    :chrome
  end
end
