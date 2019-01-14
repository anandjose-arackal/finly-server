class BaseControllers::ApiBase < ApplicationController
  authentication_scope :api
end
