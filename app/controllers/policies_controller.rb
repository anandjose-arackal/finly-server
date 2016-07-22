class PoliciesController < ApplicationController
  before_action :authenticate_user!

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
        format.html { redirect_to policy_path(@policy, view: params[:view]) }
        format.js
      end
      return
    end
    flash[:failure] = pus.errors
    render_flash_message
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
      default_mapping = mappings.default
      default_mapping = default_mapping.first if default_mapping.present?
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

end
