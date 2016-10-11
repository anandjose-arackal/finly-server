class  Api::V1::UsersController < Api::V1::BaseApiController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  respond_to :json

  def index

  end

  def show

  end

  def update

  end

end