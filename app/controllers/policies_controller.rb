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

  private
  def load_users
    @users = []
    @policy.user_mapping.each do |map|
      user = map.user
      uts = UserTeamService.new(user)
      admin = map.admin
      manager = uts.manager(policy: @policy)
      finance_manager = uts.finance_manager(policy: @policy)
      approves_to = uts.approves_to(policy: @policy)
      approves_finance_to = uts.approves_finance_to(policy: @policy)
      @users << {user: user, admin: admin, manager: manager, finance_manager: finance_manager, approves_to: approves_to, approves_finance_to: approves_finance_to}
    end
  end

end
