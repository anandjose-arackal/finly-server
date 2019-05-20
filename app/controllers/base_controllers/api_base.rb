class BaseControllers::ApiBase < ApplicationController
  protect_from_forgery with: :null_session

  def authentication_scope
    :api
  end

  def decrypt_parameters
    # check if the request encryption is required for this particular request
    if current_user&.company&.request_encryption_enabled?

    end
  end
end
