require "#{Rails.root}/app/operations/expense/manual/create"
class Mobile::V0::ReceiptsController < Mobile::V0::BaseApiController
  protect_from_forgery with: :null_session



  def create
    formatted_params = RequestFormatter::ReceiptsParser::Parse.(current_user, params)&.formatted_request
    @result = Receipt::Create.(current_user, formatted_params)
    @result.config[:mobile_api] = true
    if @result.success?
      render 'mobile/v0/shared/success'
    else
      render 'mobile/v0/shared/failure'
    end
  end

  def index
    @result = Receipt::Index.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def destroy
    @result = Receipt::Destroy.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      render 'mobile/v0/shared/success'
    else
      render 'mobile/v0/shared/failure'
    end
  end

  def update
    @result = Receipt::Update.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      render 'mobile/v0/shared/success'
    else
      render 'mobile/v0/shared/failure'
    end
  end

end
