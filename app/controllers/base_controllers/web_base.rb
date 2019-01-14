class BaseControllers::WebBase < ApplicationController
  authentication_scope :web
end
