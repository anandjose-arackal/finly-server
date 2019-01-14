class BaseControllers::PublicBase < ApplicationController
  authentication_scope :public
end
