class Api::V1::Configuration::GcmController <  Api::V1::BaseApiController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  def create
    operation = Gcm::Register.new(current_user, params)
    if operation.run
      render 'api/v1/shared/success'
    else
      render 'api/v1/shared/failure'
    end
  end

  def delete
    operation = Gcm::Unregister.new(current_user, params)
    if operation.run
      render 'api/v1/shared/success'
    else
      render 'api/v1/shared/failure'
    end
  end

end
