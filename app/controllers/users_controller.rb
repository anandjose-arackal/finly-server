class UsersController < ApplicationController

  before_action :authenticate_user!
  before_action :load_service_objects

  def profile
    @manager = @user_team_service.manager

  end

  def update_password
    @user = current_user
    if @user.update_with_password(user_params)
      # Sign in the user by passing validation in case their password changed
      sign_in @user, :bypass_sin_in => true
      flash[:success] = "Password updated"
    else
      flash.now[:danger] = "Password updation failed"
    end
    redirect_to request.referrer
  end

  # action to retrieve a particular user's details in the employees screen - only for admin, obviously
  def user_details

  end

  # for employee list
  def index
    @users = current_company.users.active.paginate(page: params[:page])
    @manager = UserTeamService.new(current_user).manager(view: 'admin')
    @finance_manager = UserTeamService.new(current_user).finance_manager(view: 'admin')
  end

  private

  def load_service_objects
    @user_team_service = UserTeamService.new(current_user)
  end

  def user_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

end
