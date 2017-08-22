class Desktop::V1::DesktopUsersController < ApplicationController

  def create
    @result = DesktopUser::Create.(params)
    respond response: @result.success? ? :success : :failure
  end

end
