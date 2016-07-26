class UsersController < ApplicationController

  #before_action :authenticate_user!
  before_action :load_service_objects

  def profile
    @manager = @user_team_service.manager
  end

  def update_password
    @user = current_user
    if @user.update_with_password(user_params)
      # Sign in the user by passing validation in case their password changed
      sign_in @user, :bypass_sin_in => true
      flash.now[:success] = 'Password updated'
    else
      flash.now[:danger] = 'Password updation failed'
    end
    redirect_to request.referrer
  end

  # action to retrieve a particular user's details in the employees screen - only for admin, obviously
  def user_details
    @user = current_company.users.with_id(params[:user_id]).first # user needs to be modified to include all user-policy related details
    # reinitializing the user team service object
    @user_team_service = UserTeamService.new(@user)
    @policies = @user.policies
    @reports = @user.reports
    # using current user instead of @user because we need list of users in current user's view
    @users = current_company.users.paginate(page: params[:page])
    load_all_mappings

    @company_managers = current_company.users.with_roles.only_managers
    @company_finance_managers = current_company.users.with_roles.only_finance_managers

    render partial: 'users/employee_profile', replace: '#employeeDetailsDiv'
  end

  # for employee list
  def index
    @user = current_user # just a placeholder, will be replaced by whichever user's details are necessary with ajax
    @policies = @user.policies
    @users = current_company.users.paginate(page: params[:page])
    @reports = @user.reports
    @company_managers = current_company.users.with_roles.only_managers
    @company_finance_managers = current_company.users.with_roles.only_finance_managers

    load_all_mappings
  end

  def update_team
    @user = current_company.users.with_id(params[:user_id]).first
    # reinitializing the user team service object
    @user_team_service = UserTeamService.new(@user)
    if @user_team_service.update(user_params)
      flash[:success] = "Team updated!"
      redirect_to users_path
    else
      flash[:danger] = @user_team_service.errors
      redirect_to users_path
    end
  end

  private

  def load_service_objects
    @user_team_service = UserTeamService.new(current_user)
  end

  def user_params
    params.require(:user).permit(:current_password, :password, :password_confirmation, :manager_id, :team_mapping_id, :finance_manager_id)
  end

  def load_all_mappings
    # loading all mappings for the user, with and without policy
    @mappings = {} # each value will be an array of mappings
    @mappings['company'] = @user_team_service.mappings
    @policies.each do |policy|
      @mappings[policy.id] = @user_team_service.mappings(policy: policy)
    end
  end

end
