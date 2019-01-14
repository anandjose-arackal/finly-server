class UserPermissionsController < BaseControllers::PublicBase

  # place where a particular user's permissions are retreived
  def show
    @result = User::Permission::Show.(current_user, params)
    respond
  end

  # for updating a particular user's permissions
  def update
    @result = User::Permission::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def check_permissions
    @result = User::Permission::CheckPermissions.(current_user, params)
    respond
  end
end
