class PoliciesController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :authenticate_user!

  def create
    @result = Policy::Create.(current_user, params)
    respond
    # redirect_to request.referrer
  end

  def destroy
    @result = Policy::Destroy.(current_user, params)
    respond
  end

  def index
    @policies = Policy::Index.(current_user, view: params[:view])
  end

  def show
    @result = Policy::Show.(current_user, params)
  end

  def details
    policy = Policy.find(params[:id])
    respond_to do |format|
      format.json {render json: policy.as_json(:only => [:name, :id]) }
    end
  end

  def expense_rules
    @result = Policy::Show.(current_user, params)
    respond_to do |format|
      format.html {render partial: 'expense_rules'}
    end
  end

  def budget_rules
    @result = Policy::Show.(current_user, params)
    respond_to do |format|
      format.html {render partial: 'budget_rules'}
    end
  end

  def policy_members
    @result = Policy::Show.(current_user, params)
    respond_to do |format|
      format.html {render partial: 'policy_members'}
    end
  end

  def create_rule
    @result = Policy::Show.(current_user, params)
    respond_to do |format|
      if params[:rule_category] == 'expense'
        format.html {render partial: 'create_expense_rule'}
      elsif params[:rule_category] == 'budget'
        format.html {render partial: 'create_budget_rule'}
      end
    end
  end

  def invitable_users
    @result = Policy::InvitableUsers.(current_user, params)
    # debugger
    respond_to do |format|
      format.html {render partial: 'users'}
    end
  end

  def policy_member_settings
    # @result = Policy::InvitableUsers.(current_user, params)
    # selected_user = User.find(params[:user_id])
    # to-do
    @target_user = User.find(params[:user_id])
    @result = Policy::Mappings::Show.(current_user, params)
    # @result = Policy::Mappings::Show.(current_user, user: params[:user_id], policy: params[:policy_id])
    # @result = User::Show.(current_user, params)
    @managers = User::Team::GetManagers.(current_user, params)
    # respond
    # debugger
    respond_to do |format|
      format.html {render partial: 'policy_member_settings'}
    end
  end



  # def invitable_users
  #   @result = Policy::InvitableUsers.(current_user, params)
  #   respond
  # end

  def add_users
    @result = Policy::Users::AddUser.(current_user, params)
    if @result.success?
      messages = @result.messages
      @result = Policy::Show.(current_user, params)
      @result.messages = messages
    end
    respond_to do |format|
      format.json {}
    end
  end

  def remove_users
    @result = Policy::Users::RemoveUser.(current_user, params)
    if @result.success?
      messages = @result.messages
      @result = Policy::Show.(current_user, params)
      @result.messages = messages
    end
    respond_to do |format|
      format.json {}
    end
  end

  def destroy_mapping
    @result = Policy::Mappings::Destroy.(current_user, params)
    if @result.success?
      messages = @result.messages
      @result = Policy::Show.(current_user, params)
      @result.messages = messages
    end
    respond
  end


  def update_user_configuration
    @result = Policy::Users::UpdateMapping.(current_user, params)
    if @result.success?
      messages = @result.messages
      @result = Policy::Show.(current_user, params)
      @result.messages = messages
    end
    respond
  end

end
