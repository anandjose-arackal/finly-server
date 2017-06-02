class Api::Cards::V1::UsersController < ApplicationController

  allow_oauth!
  before_action :authenticate_user!

  def create
    formatted_params = RequestFormatter::Api::Cards::V1::Users::Create.(user, params).formatted_request
    @result = Users::Create.(current_user, formatted_params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def index
    @result = User::Index.(current_user, params)
    respond
  end

  def show
    @result = User::Show.(current_user, params)
    respond
  end

  def update

  end

end
