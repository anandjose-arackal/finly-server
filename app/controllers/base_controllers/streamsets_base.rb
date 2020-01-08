class BaseControllers::StreamsetsBase < ApplicationController

  protect_from_forgery with: :null_session

  def authentication_scope
    :streamsets
  end

end
