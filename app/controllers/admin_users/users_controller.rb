class AdminUsers::UsersController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def new
    @states = State.all
  end

  def create
    @result = Admin::Users::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = Admin::Users::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show
    @result = Admin::Users::Show.(current_user, params)
    respond
  end

  def index
    @result = Admin::Users::Index.(current_user, params)
    respond
  end

  # returns the respective menus that a particular user has access to
  def admin_menus
    @result = Admin::AdminRolePermissions::Show.(current_user, params)
    respond_to do |format|
      format.json {
        render json: @result.as_json
      }
    end
  end

  def lookup
    @result = Admin::Users::Lookup.(params)
    respond
  end

  def set_role
    @result = Admin::Users::Role::SetRole.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update_status
    @result = Admin::Users::State::UpdateStatus.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update_mapping
    @result = Admin::Users::Team::Mappings::Set.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def destroy_mapping
    @result = Admin::Users::Team::Mappings::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def admin_welcome
    @result = Admin::Users::WelcomeMail.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  private

end
