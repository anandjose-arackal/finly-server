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

    # @states = State.all
    # @user = User.find_by(id: params[:id])
    # if @user.nil?
    #   redirect_to superadmin_company_users_path(params[:company_id])
    # end
  end

  # returns the respective menus that a particular user has access to
  def admin_menus
    # junk data for menu data
    @result = {
        views: {
            admin: {
                menus: {
                    navbar: [
                       {
                           name: "Companies",
                           url: "/companies"
                       },
                       {
                           name: "Users",
                           url: "/users"
                       },
                       {
                           name: "Reports",
                           url: "/reports"
                       },
                       {
                           name: "Expenses",
                           url: "/expenses"
                       },
                       {
                           name: "Cards",
                           url: "/cards"
                       }
                    ]
                }
            }
        }
    }
    respond_to do |format|
      format.json {
        render json: @result.as_json
      }
    end
  end

end
