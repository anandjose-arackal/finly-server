class Api::V1::Configuration::GcmController <  Api::V1::BaseApiController
  protect_from_forgery with: :null_session



  def create
    @result = Gcm::Register.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      render 'api/v1/shared/success'
    else
      render 'api/v1/shared/failure'
    end
  end

  def delete
    @result = Gcm::Unregister.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      render 'api/v1/shared/success'
    else
      render 'api/v1/shared/failure'
    end
  end

end
