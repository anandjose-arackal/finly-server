class Mobile::V1::Configuration::GcmController <  Mobile::V1::BaseApiController
  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :mobile}


  def create
    @result = Gcm::Register.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      render 'mobile/v1/shared/success'
    else
      render 'mobile/v1/shared/failure'
    end
  end

  def delete
    @result = Gcm::Unregister.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      render 'mobile/v1/shared/success'
    else
      render 'mobile/v1/shared/failure'
    end
  end

end
