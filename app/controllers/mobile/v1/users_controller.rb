class  Mobile::V1::UsersController < Mobile::V1::BaseApiController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

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

end