class UsersController < ApplicationController

  before_action :authenticate_user!
  # before_action :load_service_objects
  # before_action :load_update_role_ids, only: [:update_user_role]
  before_action :load_user_counts, only: [:index, :show]

  has_scope :filter_search
  has_scope :filter_role
  has_scope :filter_status


  # # show action to show user profile
  # def show
  #   @mappings = current_user.team_mapping.policy(nil)
  #   @assigned_policies = current_user.policies
  # end

  # action to retrieve a particular user's details in the users screen - for everyone with a team - manager, finance manager etc.
  def show
    # this will be the user whose details are to be shown
    @user = current_company.users.find_by(id: params[:user_id] || params[:id])
    # reinitializing the user team service object
    retrieve_policies
    @company_policies = current_company.policies
    @reports = @user.reports.not_open
    # using current user instead of @user because we need list of users in current user's view
    @users = apply_scopes(load_team).paginate(page: params[:page])
    load_all_mappings

    @company_managers = current_company.users.with_roles.only_managers.signed_up
    @company_finance_managers = current_company.users.with_roles.only_finance_managers.signed_up

    if @user.invite_accepted?
      render partial: 'users/edit_invite', replace: '#inviteDetaislDiv'
    else
      render partial: 'users/employee_profile', replace: '#employeeDetailsDiv'
    end

    respond_to do |format|
      format.json {render json: @user.as_json}
    end
  end

  # this would call the respective private method to update the respective attributes
  def update
    update_handler(params[:type])
  end

  # for list of team members - currently sending instance variables based on what was shown in the previous user listing
  def index
    @users = load_team
    # @user = current_user
    # retrieve_policies
    # @company_policies = current_company.policies
    # @users = apply_scopes(load_team).paginate(page: params[:page], per_page: 30)
    # @reports = @user.reports.not_open
    # @company_managers = current_company.users.with_roles.only_managers.signed_up
    # @company_finance_managers = current_company.users.with_roles.only_finance_managers.signed_up
    #
    # load_all_mappings

    respond_to do |format|
      format.json {render json: @users.as_json}
    end
  end

  # def profile
  #   authorize User
  #   @manager = @user_team_service.manager
  #   @assigned_policies = current_user.policies
  # end

  # def update_password
  #   @user = current_user
  #   authorize @user
  #   if @user.update_with_password(user_params)
  #     # Sign in the user by passing validation in case their password changed
  #     sign_in @user, :bypass => true
  #     flash.now[:success] = 'Password updated'
  #   else
  #     flash.now[:danger] = 'Password updation failed'
  #   end
  #   render_flash_message
  # end




  # def update_team
  #   authorize User
  #   @user = current_company.users.with_id(params[:user_id]).first
  #   # reinitializing the user team service object
  #   @user_team_service = UserTeamService.new(@user)
  #   # updating the default team mapping
  #   if @user_team_service.update(user_team_params['default'])
  #     @default_success = true
  #   else
  #     flash.now[:danger] = @user_team_service.errors
  #     render_flash_message
  #   end
  #   # updating all the non default mappings - or creating it if it doesn't exist.
  #   if update_non_default_teams
  #     flash[:success] = "Team updated!"
  #   else
  #     flash[:danger] = @user_team_service.errors
  #   end
  #   redirect_to request.referrer
  # end
  #
  # def update_user_role
  #   @user = current_company.users.find_by(id: params[:user_id])
  #   @user_team_service = UserTeamService.new(@user)
  #   if @user_team_service.update_role(user_role_id: @new_role_ids) and @user_team_service.remove_role(user_role_id: @removable_user_ids)
  #     flash[:success] = "Role updated. "
  #     render_flash_message
  #   else
  #     flash[:error] = @user_team_service.errors
  #     render_flash_message
  #   end
  # end


  private

  def load_user_counts
    @users_type_count = current_company.users.joins(:role_mapping).group(:user_role_id).count
    @users_status_count = current_company.users.group(:active).count
    @pending_invites_count = current_company.users.pending.count
  end

  # def load_update_role_ids
  #   @user = current_company.users.find_by(id: params[:user_id])
  #   @new_role_ids = []
  #   @removable_user_ids = []
  #   if params[:admin] == '1'
  #     @new_role_ids << 1
  #   elsif params[:admin] == '0' and @user.admin?
  #     @removable_user_ids << 1
  #   end
  #   if params[:manager] == '1'
  #     @new_role_ids << 3
  #   elsif params[:manager] == '0' and @user.manager?
  #     @removable_user_ids << 3
  #   end
  #   if params[:finance_manager] == '1'
  #     @new_role_ids << 2
  #   elsif params[:finance_manager] == '0' and @user.finance_manager?
  #     @removable_user_ids << 2
  #   end
  # end
  #
  # def load_service_objects
  #   @user_team_service = UserTeamService.new(current_user)
  # end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  # def user_team_params
  #   params.require(:user_team).permit!
  # end

  def retrieve_policies
    # @user is the user whose details are being seen by the admin
    if current_user.admin? and (params['view'] == 'admin' or params[:view] == 'admin')
      @policies = current_company.policies
    elsif current_user.manager? and (params['view'] == 'manager' or params[:view] == 'manager')
      @policies = @user.admin_policies
    end
  end

  def load_team
    if current_user.admin?
      return current_company.users
    elsif current_user.manager?
      return User::Team::Show.new(current_user, role_id: UserRole.manager_id).run.team
    elsif current_user.finance_manager?
      return User::Team::Show.new(current_user, role_id: UserRole.finance_manager_id).run.team
    else
      [] # return empty array
    end
  end

  def load_all_mappings
    # loading all mappings for the user, with and without policy
    @mappings = {} # each value will be an array of mappings
    @mappings['company'] = @user.team_mapping.policy(nil)
    @policies.each do |policy|
      @mappings[policy.id] = @user.team_mapping.policy(policy_id: policy.id)
    end
  end
  #
  # def update_non_default_teams
  #   # create or update the conditional manager
  #   if user_team_params['non_default']['conditional_manager'].present? and user_team_params['non_default']['conditional_manager']['team_mapping_id'].present?
  #     # i.e. updating conditional manager mapping
  #     unless @user_team_service.update(user_team_params['non_default']['conditional_manager'])
  #       flash[:danger] = @user_team_service.errors
  #       @non_default_success = false
  #       return false
  #     end
  #   elsif user_team_params['non_default']['conditional_manager'].present? and user_team_params['non_default']['conditional_manager']['amount'].present?
  #     # i.e. there is no conditional mapping but one needs to be created
  #     unless @user_team_service.create(user_team_params['non_default']['conditional_manager'])
  #       flash[:danger] = @user_team_service.errors
  #       @non_default_success = false
  #       return false
  #     end
  #   end
  #
  #   # create or update the conditional finance manager
  #   if user_team_params['non_default']['conditional_finance_manager'].present? and user_team_params['non_default']['conditional_finance_manager']['team_mapping_id'].present?
  #     # i.e. updating conditional manager mapping
  #     unless @user_team_service.update(user_team_params['non_default']['conditional_finance_manager'])
  #       flash[:danger] = @user_team_service.errors
  #       @non_default_success = false
  #       return false
  #     end
  #   elsif user_team_params['non_default']['conditional_finance_manager'].present? and user_team_params['non_default']['conditional_finance_manager']['amount'].present?
  #     # i.e. there is no conditional mapping but one needs to be created
  #     unless @user_team_service.create(user_team_params['non_default']['conditional_finance_manager'])
  #       flash[:danger] = @user_team_service.errors
  #       @non_default_success = false
  #       return false
  #     end
  #   end
  #
  #   # create or update the conditional approves to user
  #   if user_team_params['non_default']['conditional_approves_to'].present? and user_team_params['non_default']['conditional_approves_to']['team_mapping_id'].present?
  #     # i.e. updating conditional manager mapping
  #     unless @user_team_service.update(user_team_params['non_default']['conditional_approves_to'])
  #       flash[:danger] = @user_team_service.errors
  #       @non_default_success = false
  #       return false
  #     end
  #   elsif user_team_params['non_default']['conditional_approves_to'].present? and user_team_params['non_default']['conditional_approves_to']['amount'].present?
  #     # i.e. there is no conditional mapping but one needs to be created
  #     unless @user_team_service.create(user_team_params['non_default']['conditional_approves_to'])
  #       flash[:danger] = @user_team_service.errors
  #       @non_default_success = false
  #       return false
  #     end
  #   end
  #
  #   # create or update the conditional approves finance to user
  #   if user_team_params['non_default']['conditional_approves_finance_to'].present? and user_team_params['non_default']['conditional_approves_finance_to']['team_mapping_id'].present?
  #     # i.e. updating conditional manager mapping
  #     unless @user_team_service.update(user_team_params['non_default']['conditional_approves_finance_to'])
  #       flash[:danger] = @user_team_service.errors
  #       @non_default_success = false
  #       return false
  #     end
  #   elsif user_team_params['non_default']['conditional_approves_finance_to'].present? and user_team_params['non_default']['conditional_approves_finance_to']['amount'].present?
  #     # i.e. there is no conditional mapping but one needs to be created
  #     unless @user_team_service.create(user_team_params['non_default']['conditional_approves_finance_to'])
  #       flash[:danger] = @user_team_service.errors
  #       @non_default_success = false
  #       return false
  #     end
  #   end
  #   # return true of all are successful
  #   true
  # end

  def update_handler(type = nil)
    unless type
      flash[:error] = "Invalid data."
      # display error
      return
    end
    case type
      when :password
        if current_user.update_with_password(password_params)
          # Sign in the user by passing validation in case their password changed
          sign_in @user, :bypass => true
          flash.now[:success] = 'Password updated'
        else
          flash.now[:danger] = 'Password updation failed'
        end
        render_flash_message
        return
      when :team
        update_team_op = User::Team::UpdateConfiguration.new(current_user, params)
        # updating the team mapping, along with conditional managers and finances
        if update_team_op.run
          flash[:success] = "User team updated."
          redirect_to request.referrer
        else
          flash.now[:danger] = update_team_op.errors
          render_flash_message
          return
        end
      when :role
        set_role_op = User::Role::Set.new(current_user, params)
        if set_role_op.run
          flash[:success] = "Role updated"
          redirect_to request.referrer
        else
          flash.now[:danger] = set_role_op.errors
          return
        end
      else
        # do nothing, ha!
    end
  end

end
