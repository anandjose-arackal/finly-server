class PoliciesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_service_objects

  has_scope :filter_name
  has_scope :filter_email

  def create
    pcs = PolicyCreateService.new(current_user)
    if pcs.create_policy(params[:name])
      flash.now[:success] = 'Policy Created'
      render_flash_message
      return
    end
    flash.now[:failure] = pcs.errors
    render_flash_message
  end

  def index
    prs = PolicyRetrievalService.new(current_user)
    @policies = prs.list params
  end

  def show
    @policy = Policy.find(params[:id])
    @managers = @policy.company.managers
    @finance_managers = @policy.company.finance_managers
    @categories = current_company.categories.active
    load_users

  end

  def invitable_users
    @policy = Policy.find(params[:policy_id])
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

  def add_users
    @policy = Policy.find(params[:policy_id])
    ids = []
    ids = params[:user_id].split(/,/) unless params[:user_id].blank?
    users = PolicyUserService.new(@policy).invitable_users.with_id(ids)
    pus = PolicyUserService.new(@policy)
    if pus.add_users(users)
      load_users
      respond_to do |format|
        format.html {}
        format.js
      end
      return
    end
    flash.now[:danger] = pus.errors
    render_flash_message
  end

  def remove_users
    @policy = Policy.find(params[:policy_id])
    ids = []
    ids = params[:user_id].split(/,/) unless params[:user_id].blank?
    users = @policy.users.with_id(ids)
    pus = PolicyUserService.new(@policy)
    if pus.remove_users(users)
      load_users
      respond_to do |format|
        format.html {}
        format.js { render 'add_users' }
      end
      return
    end
    flash.now[:danger] = pus.errors
    render_flash_message
  end

  def update

  end

  def destroy

  end

  def update_user_configuration
    @policy = Policy.find(params[:policy_id])
    pus = PolicyUserService.new(@policy)
    if pus.update_configuration params[:policy]
      load_users
      flash.now[:success] = 'Configuration updated'
      respond_to do |format|
        format.html { redirect_to request.referrer }
        format.js
      end
      return
    end
    flash.now[:failure] = pus.errors
    render_flash_message
  end


  def add_rule
    # determine the type of rule and call the respective service method
    if rule_params['greater_than_amount_attributes']
      if @rule_service.add_expense_rule(rule_params)
        flash[:success] = "Expense Rule added!"
      else
        flash[:danger] = @rule_service.errors
      end
    elsif rule_params['amount_attributes']
      if @rule_service.add_budget_rule(rule_params)
        flash[:success] = "Budget Rule added"
      else
        flash[:danger] = @rule_service.errors
      end
    else
      flash[:danger] = "Invalid input params."
    end
    redirect_to request.referrer
  end

  def remove_rule
    # determine the type of rule being added and accordingly update
    if params['budget_rule']
      if @rule_service.remove_budget_rule(params['budget_rule']['rule_id'])
        flash[:success] = "Expense Rule removed!"
      else
        flash[:danger] = @rule_service.errors
      end
    elsif params['expense_rule']
      if @rule_service.remove_expense_rule(params['expense_rule']['rule_id'])
        flash[:success] = "Budget rule removed!"
      else
        flash[:danger] = @rule_service.errors
      end
    else
      flash[:danger] = "Invalid input params."
    end
    redirect_to request.referrer
  end

  private
  def load_users
    @users = []
    @policy.user_mapping.each do |map|
      user = map.user
      uts = UserTeamService.new(user)
      admin = map.admin
      conditional_manager= nil
      conditional_finance =nil
      conditional_approves_to = nil
      conditional_approves_finance_to = nil

      mappings = uts.mappings policy: @policy
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

  def update_user_params
    params.require(:policy).permit(:admin, :default, :conditional_manager, :conditional_finance_manager,
                                   :conditional_approves_to, :conditional_approves_finance_to)
  end

  def rule_params
    params.require(:rule).permit!
  end

  def load_service_objects
    @rule_service = RuleService.new(current_user, params[:policy_id])
  end

end
