class PoliciesController < ApplicationController
  before_action :authenticate_user!

  has_scope :filter_name
  has_scope :filter_email

  def create
    pcs = PolicyCreateService.new(current_user)
    if pcs.create_policy(params[:name])
      flash[:success] = 'Policy Created'
      render_flash_message
      return
    end
    flash[:failure] = pcs.errors
    render_flash_message
  end

  def index
    prs = PolicyRetrievalService.new(current_user)
    @policies = prs.list params
  end

  def show
    @policy = Policy.find(params[:id])
    @managers = @policy.company.managers
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

  def invitable_users
    @policy = Policy.find(params[:policy_id])
    u = PolicyUserService.new(@policy).invitable_users
    u = apply_scopes(u)
    manager_id = params[:filter_manager_id]
    if manager_id.present?
      managers = @policy.company.users.with_id(manager_id)
      if managers.present?
        manager = managers.first
        manager_team = UserTeamService.new(manager).team(view: 'manager')
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

  def update

  end

  def destroy

  end

end
