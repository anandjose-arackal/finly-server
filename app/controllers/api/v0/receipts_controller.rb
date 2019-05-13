require "#{Rails.root}/app/operations/expense/manual/create"
class Api::V0::ReceiptsController < Api::V0::BaseApiController
  protect_from_forgery with: :null_session



  def create
    RequestFormatter.parse_receipt(current_user, params)
    @result = Receipt::Create.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      render 'api/v0/shared/success'
    else
      render 'api/v0/shared/failure'
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
      render 'api/v0/shared/success'
    else
      render 'api/v0/shared/failure'
    end
  end

  def update
    @result = Receipt::Update.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      render 'api/v0/shared/success'
    else
      render 'api/v0/shared/failure'
    end
  end

end
