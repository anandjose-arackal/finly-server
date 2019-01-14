class BaseControllers::MobileBase < ApplicationController
  authentication_scope :mobile
end
