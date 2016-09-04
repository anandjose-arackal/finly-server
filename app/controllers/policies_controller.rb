class PoliciesController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :authenticate_user!

  has_scope :filter_name
  has_scope :filter_email

  def create
    create_policy_op = Policy::Create.new(current_user, params)
    @policy = create_policy_op.run
    if @policy
      flash.now[:success] = 'Policy Created'
      @policies = Policy::Index.new(current_user, view: 'admin')
      render partial: 'organization_account/policy_list', replace: '#policyListAdmin'
      return
    end
    flash.now[:failure] = create_policy_op.errors
    render_flash_message
  end

  def destroy
    destroy_op = Policy::Destroy.new(current_user, params)
    @result = destroy_op.run
    if @result
      flash.now[:success] = "Policy destroyed."
      respond_to do |format|
        format.json { render json: {"status": "success"} }
      end
    else
      flash[:danger] = update_op.errors
      render_flash_message
    end
  end

  def index
    index_op = Policy::Index.new(current_user, view: params[:view])
    @policies = index_op.run.policies
  end

  def show
    @policy = Policy.find(params[:id])
    authorize @policy
    @managers = @policy.company.managers
    @finance_managers = @policy.company.finance_managers
    @categories = current_company.categories.active
    load_users
  end

  def invitable_users
    @policy = Policy.find_by(id: params[:policy_id])
    authorize @policy
    u = PolicyUserService.new(@policy).invitable_users.sort_by_name
    u = apply_scopes(u)
    manager_id = params[:filter_manager_id]
    if manager_id.present?
      managers = @policy.company.users.with_id(manager_id)
      if managers.present?
        manager = managers.first
        manager_team = UserTeamService.new(manager).team(UserRole.manager_id)
        new_u = nil
        if manager_team.present?
          new_u = u.with_id(manager_team.pluck(:id))
        end
        u = new_u
      end
    end
    @users = []
    if u.present?
      u.each do |user|
        manager = UserTeamService.new(user).manager
        manager_email = nil
        manager_email = manager.email if manager.present?
        @users << {user: user, manager: manager_email}
      end
    end
    respond_to do |format|
      format.html {}
      format.js
    end
  end

  def add_user
    add_user_op = Policy::Users::Add.new(current_user, params)
    if add_user_op.run
      flash[:success] = "User successfully addded"
      redirect_to request.referrer
    else
      flash[:danger] = add_user_op.errors
      # render error message
    end
    # @policy = Policy.find(params[:policy_id])
    # authorize @policy
    # ids = []
    # ids = params[:user_id].split(/,/) unless params[:user_id].blank?
    # users = PolicyUserService.new(@policy).invitable_users.with_id(ids)
    # pus = PolicyUserService.new(@policy)
    # if pus.add_users(users)
    #   load_users
    #   respond_to do |format|
    #     format.html {}
    #     format.js
    #   end
    #   return
    # end
    # flash.now[:danger] = pus.errors
    # render_flash_message
  end

  def remove_users
    add_user_op = Policy::Users::Add.new(current_user, params)
    if add_user_op.run
      flash[:success] = "User successfully addded"
      redirect_to request.referrer
    else
      flash[:danger] = add_user_op.errors
      # render error message
    end
    # @policy = Policy.find(params[:policy_id])
    # authorize @policy
    # ids = []
    # ids = params[:user_id].split(/,/) unless params[:user_id].blank?
    # users = @policy.users.with_id(ids)
    # pus = PolicyUserService.new(@policy)
    # if pus.remove_users(users)
    #   load_users
    #   respond_to do |format|
    #     format.html {}
    #     format.js { render 'add_users' }
    #   end
    #   return
    # end
    # flash.now[:danger] = pus.errors
    # render_flash_message
  end


  def update_user_configuration
    update_configuration_op = Policy::Users::UpdateConfiguration.new(current_user, params)
    if update_configuration_op.run
      flash[:success] = "Configuration updated"
      redirect_to request.referrer
    else
      flash[:danger] = "Update failed."
      # render flash message
    end
    # @policy = Policy.find(params[:policy_id])
    # authorize @policy
    # pus = PolicyUserService.new(@policy)
    # if pus.update_configuration params[:policy]
    #   load_users
    #   flash.now[:success] = 'Configuration updated'
    #   respond_to do |format|
    #     format.html { redirect_to request.referrer }
    #     format.js
    #   end
    #   return
    # end
    # flash.now[:failure] = pus.errors
    # render_flash_message
  end
  #
  # def add_rule
  #   @policy = Policy.find(params[:policy_id])
  #   authorize @policy
  #   # determine the type of rule and call the respective service method
  #   if rule_params['greater_than_amount_attributes']
  #     if @rule_service.add_expense_rule(rule_params)
  #       flash[:success] = "Expense Rule added!"
  #     else
  #       flash[:danger] = @rule_service.errors
  #     end
  #   elsif rule_params['amount_attributes']
  #     if @rule_service.add_budget_rule(rule_params)
  #       flash[:success] = "Budget Rule added"
  #     else
  #       flash[:danger] = @rule_service.errors
  #     end
  #   else
  #     flash[:danger] = "Invalid input params."
  #   end
  #   redirect_to request.referrer
  # end
  #
  # def remove_rule
  #   @policy = Policy.find(params[:policy_id])
  #   authorize @policy
  #   # determine the type of rule being added and accordingly update
  #   if params['budget_rule']
  #     if @rule_service.remove_budget_rule(params['budget_rule']['rule_id'])
  #       flash[:success] = "Expense Rule removed!"
  #     else
  #       flash[:danger] = @rule_service.errors
  #     end
  #   elsif params['expense_rule']
  #     if @rule_service.remove_expense_rule(params['expense_rule']['rule_id'])
  #       flash[:success] = "Budget rule removed!"
  #     else
  #       flash[:danger] = @rule_service.errors
  #     end
  #   else
  #     flash[:danger] = "Invalid input params."
  #   end
  #   redirect_to request.referrer
  # end

  private
  def load_users
    @users = []
    @policy.user_mapping.each do |map|
      user = map.user
      admin = map.admin
      conditional_manager= nil
      conditional_finance =nil
      conditional_approves_to = nil
      conditional_approves_finance_to = nil

      mappings = user.team_mapping.with_details.policy(@policy.id)
      dm = mappings.default
      default_mapping = dm.first if dm.present?
      conditional_mapping = mappings.non_default
      cm = conditional_mapping.manager
      conditional_manager = cm.first if cm.present?
      cf = conditional_mapping.finance_manager
      conditional_finance = cf.first if cf.present?
      cat = conditional_mapping.approves_to
      conditional_approves_to = cat.first if cat.present?
      caft = conditional_mapping.approves_finance_to
      conditional_approves_finance_to = caft.first if caft.present?

      @users << {user: user, admin: admin, default_mapping: default_mapping, conditional_manager: conditional_manager,
                 conditional_finance: conditional_finance, conditional_approves_to: conditional_approves_to,
                 conditional_approves_finance_to: conditional_approves_finance_to}
    end
  end

  # def update_user_params
  #   params.require(:policy).permit(:admin, :default, :conditional_manager, :conditional_finance_manager,
  #                                  :conditional_approves_to, :conditional_approves_finance_to)
  # end
  #
  # def rule_params
  #   params.require(:rules).permit!
  # end

  # def load_service_objects
  #   @rule_service = RuleService.new(current_user, params[:policy_id])
  # end

end
