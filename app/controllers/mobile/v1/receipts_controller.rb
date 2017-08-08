require "#{Rails.root}/app/operations/expense/manual/create"
class Mobile::V1::ReceiptsController < Mobile::V1::BaseApiController
  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :mobile}


  def create
    formatted_params = RequestFormatter::ReceiptsParser::Parse.(current_user, params)&.formatted_request
    @result = Receipt::Create.(current_user, formatted_params)
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
