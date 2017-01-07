class Superadmin::UsersController < ApplicationController

  def new
    @states = State.all
  end

  def create
    @result = Superadmin::User::Create.(current_user, params)
    if @result.success?
      flash[:success] = "User created"
      redirect_to superadmin_company_path(params[:company_id])
    else
      flash[:error] = @result.messages[:error]
      redirect_to request.referrer
    end
  end

  def update
    @result = Superadmin::User::Update.(current_user, params)
    if @result.success?
      flash[:success] = "User updated"
      redirect_to superadmin_company_path(params[:company_id])
    else
      flash[:error] = @result.messages[:error]
      redirect_to request.referrer
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
