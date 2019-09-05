class Api::V1::Configuration::FieldConfigurationsController < BaseControllers::ApiBase
  protect_from_forgery with: :null_session
  rescue_from NotAuthorizedException, with: :un_authorized

  def create

  end

  def index

  end

  def show

  end

  def update

  end
end


