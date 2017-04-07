class FinlyAdmin::UsersController < ApplicationController

  def new
    @states = State.all
  end

  def create
    @result = Superadmin::User::Create.(current_user, params)
    respond_to do |format|
      format.json {}
    end
  end

  def update
    @result = Superadmin::User::Update.(current_user, params)
    respond_to do |format|
      format.json {}
    end
  end

  def show
    @states = State.all
    @user = User.find_by(id: params[:id])
    if @user.nil?
      redirect_to superadmin_company_users_path(params[:company_id])
    end
  end

end
