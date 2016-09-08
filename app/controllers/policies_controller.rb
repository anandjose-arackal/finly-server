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
      flash[:danger] = destroy_op.errors
      render_flash_message
    end
  end

  def index
    index_op = Policy::Index.new(current_user, view: params[:view])
    @policies = index_op.run.policies
  end

  def show
    show_op = Policy::Show.new(current_user, params)
    @result = show_op.run
  end

  def invitable_users
    invitable_users_op = Policy::InvitableUsers.new(current_user, params)
    @result = invitable_users_op.run
    respond_to do |format|
      format.html {}
      format.js
    end

  end

  def add_users
    add_user_op = Policy::Users::AddUser.new(current_user, params)
    if add_user_op.run
      flash[:success] = "User successfully addded"
      redirect_to request.referrer
    else
      flash[:danger] = add_user_op.errors
      # render error message
    end
  end

  def remove_users
    remove_user_op = Policy::Users::RemoveUser.new(current_user, params)
    if remove_user_op.run
      flash[:success] = "User successfully removed"
      redirect_to request.referrer
    else
      flash[:danger] = remove_user_op.errors
      # render error message
    end
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
  end

  private

  # def load_users
  #   @users = []
  #   @policy.user_mapping.each do |map|
  #     user = map.user
  #     admin = map.admin
  #     conditional_manager = nil
  #     conditional_finance = nil
  #     conditional_approves_to = nil
  #     conditional_approves_finance_to = nil
  #
  #     mappings = user.team_mapping.with_details.policy(@policy.id)
  #     dm = mappings.default
  #     default_mapping = dm.first if dm.present?
  #     conditional_mapping = mappings.non_default
  #     cm = conditional_mapping.manager
  #     conditional_manager = cm.first if cm.present?
  #     cf = conditional_mapping.finance_manager
  #     conditional_finance = cf.first if cf.present?
  #     cat = conditional_mapping.approves_to
  #     conditional_approves_to = cat.first if cat.present?
  #     caft = conditional_mapping.approves_finance_to
  #     conditional_approves_finance_to = caft.first if caft.present?
  #
  #     @users << {user: user, admin: admin, default_mapping: default_mapping, conditional_manager: conditional_manager,
  #                conditional_finance: conditional_finance, conditional_approves_to: conditional_approves_to,
  #                conditional_approves_finance_to: conditional_approves_finance_to}
  #   end
  # end

end
