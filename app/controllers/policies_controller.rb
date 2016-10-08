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

  def invitable_users
    @result = Policy::InvitableUsers.(current_user, params)
    respond
  end

  def add_users
    @result = Policy::Users::AddUser.(current_user, params)
    if @result.success?
      messages = @result.messages
      @result = Policy::Show.(current_user, params)
      @result.messages = messages
    end
    respond
  end

  def remove_users
    @result = Policy::Users::RemoveUser.(current_user, params)
    if @result.success?
      messages = @result.messages
      @result = Policy::Show.(current_user, params)
      @result.messages = messages
    end
    respond
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
