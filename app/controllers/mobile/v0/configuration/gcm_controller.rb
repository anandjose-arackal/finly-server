class Api::V0::Configuration::GcmController <  Api::V0::BaseApiController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  def create
    operation = Gcm::Register.new(current_user, params)
    if operation.run
      render 'mobile/v0/shared/success'
    else
      render 'mobile/v0/shared/failure'
    end
  end

  def delete
    operation = Gcm::Unregister.new(current_user, params)
    if operation.run
      render 'mobile/v0/shared/success'
    else
      render 'mobile/v0/shared/failure'
    end
  end

end
