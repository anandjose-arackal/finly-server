class Api::V1::BaseApiController < ApplicationController
  rescue_from NotAuthorizedException, with: :un_authorized

  before_action :format

  def un_authorized
    render 'api/v1/shared/failure'
  end

  private
  def format
    Formatter.handle_api_nil params
  end

end