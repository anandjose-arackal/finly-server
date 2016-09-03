class Api::V1::BaseApiController < ApplicationController
  rescue_from NotAuthorizedException, with: :un_authorized

  def un_authorized
    render 'api/v1/shared/failure'
  end

end