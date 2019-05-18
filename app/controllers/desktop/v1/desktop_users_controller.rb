class Desktop::V1::DesktopUsersController < BaseControllers::PublicBase

  def create
    @result = DesktopUser::Create.(params)
    respond response: @result.success? ? :success : :failure
  end

end
