class Mobile::V0::Configuration::GcmController <  Mobile::V0::BaseApiController
  protect_from_forgery with: :null_session

  before_action -> { doorkeeper_authorize! :mobile}


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
