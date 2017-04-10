class AdminUsers::UsersController < ApplicationController
  allow_oauth!

  # before_action :authenticate_admin_user!

  def new
    @states = State.all
  end

  def create
    @result = Admin::User::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = Admin::User::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show

  end

  def index
    @result = Admin::User::Index.(current_user, params)
    respond
  end

  # returns the respective menus that a particular user has access to
  def admin_menus
    current_user = AdminUser.first
    # junk data for menu data
    @result = Admin::AdminRolePermissions::Show.(current_user, params)
    respond_to do |format|
      format.json {
        render json: @result.as_json
      }
    end
  end

end
