class AdminUsers::UsersController < ApplicationController
  allow_oauth!

  # before_action :authenticate_admin_user!

  # todo - temporary
  before_action :set_dummy_user

  def new
    @states = State.all
  end

  def create
    @result = Admin::Users::Create.(@dummy_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = Admin::Users::Update.(@dummy_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show
    @result = Admin::Users::Show.(@dummy_user, params)
  end

  def index
    # todo - temporary, the current user is passed as the the first admin user - will be changed once login is implemented
    @result = Admin::Users::Index.(AdminUser.first, params)
    respond
  end

  # returns the respective menus that a particular user has access to
  def admin_menus
    @dummy_user = AdminUser.first
    # junk data for menu data
    @result = Admin::AdminRolePermissions::Show.(@dummy_user, params)
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
    @result = Admin::Users::Role::SetRole.(@dummy_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update_status
    @result = Admin::Users::State::UpdateStatus.(@dummy_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  private

  def set_dummy_user
    @dummy_user = AdminUser.first
  end

end
