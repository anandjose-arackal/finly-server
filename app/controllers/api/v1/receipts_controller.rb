require "#{Rails.root}/app/operations/expense/manual/create"
class Api::V1::ReceiptsController < Api::V1::BaseApiController
  protect_from_forgery with: :null_session



  def create
    RequestFormatter.parse_receipt(current_user, params)
    @result = Receipt::Create.(current_user, params)
    @result.config[:mobile_api] = true
    unless @result.success?
      respond response: :failure
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
    respond response: (@result.success? ? :success : :failure)
  end

  def update
    @result = Receipt::Update.(current_user, params)
    @result.config[:mobile_api] = true
    respond response: (@result.success? ? :success : :failure)
  end

end
