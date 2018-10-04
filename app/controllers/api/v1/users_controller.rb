class  Api::V1::UsersController < Api::V1::BaseApiController
  protect_from_forgery with: :null_session

  before_action -> { finly_authorize!(:mobile, :api) }

  respond_to :json

  def index
    @result = User::Index.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def show
    @result = User::Show.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def summary
    @result = User::Summary.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end
  
  def balance
    @result = User::Balance.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def create
    @result = Users::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = Users::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def deactivate_user
    @result = Users::Deactivate.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

end