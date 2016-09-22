class PoliciesController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :authenticate_user!

  def create
    create_policy_op = Policy::Create.new(current_user, params)
    @result = create_policy_op.run
    if @result.success?
      flash.now[:success] = 'Policy Created'
      respond_to do |format|
        format.js {}
      end
    else
      flash.now[:failure] = create_policy_op.messages[:error]
    end
    respond_to do |format|
      format.js {}
    end
    # redirect_to request.referrer
  end

  def destroy
    destroy_op = Policy::Destroy.new(current_user, params)
    @result = destroy_op.run
    if @result.success?
      flash.now[:success] = "Policy destroyed."
      respond_to do |format|
        format.js {}
      end
    else
      flash[:danger] = destroy_op.messages[:error]
    end
    # redirect_to request.referrer
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
    @result = Policy::Users::AddUser.(current_user, params)
    if @result.success?
      flash[:success] = 'User successfully addded'
      # redirect_to request.referrer
      respond_to do |format|
        format.js {}
      end
    else
      flash[:danger] = @result.messages[:error]
      # render error message
    end
  end

  def remove_users
    @result = Policy::Users::RemoveUser.(current_user, params)
    if @result.success?
      flash[:success] = 'User successfully removed'
      # redirect_to request.referrer
      respond_to do |format|
        format.js {}
      end
    else
      flash[:danger] = @result.messages[:error]
      # render error message
    end
  end


  def update_user_configuration
    update_configuration_op = Policy::Users::UpdateMapping.new(current_user, params)
    @result = update_configuration_op.run
    if @result.success?
      @result = Policy::Show.new(current_user, params).run
      flash[:success] = "Configuration updated"
      # redirect_to request.referrer
      respond_to do |format|
        format.js {}
      end
    else
      flash[:danger] = update_configuration_op.messages[:error]
      # render flash message
    end
  end

end
