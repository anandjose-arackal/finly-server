class Api::Cards::V1::UsersController < ApplicationController

  allow_oauth!
  before_action :authenticate_user!

  def create

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
